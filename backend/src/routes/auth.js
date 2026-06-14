import { Router } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { v4 as uuid } from 'uuid';
import { query } from '../config/db.js';
import { JWT_SECRET, JWT_EXPIRES_IN } from '../config/env.js';
import { auth } from '../middleware/auth.js';

const router = Router();

function generateUniqueId(name) {
  const clean = name.toLowerCase().replace(/[^a-z0-9]/g, '');
  const suffix = Date.now().toString().slice(-4);
  return `@${clean}${suffix}`;
}

function generateReferralCode(name) {
  const clean = name.toLowerCase().replace(/[^a-z0-9]/g, '');
  const suffix = Date.now().toString().slice(-3);
  return `${clean.slice(0, 3)}${suffix}`.toUpperCase();
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { phone, name, password, role } = req.body;
    if (!phone || !name || !password) {
      return res.status(400).json({ error: 'Champs requis: phone, name, password' });
    }

    const existing = await query('SELECT id FROM profiles WHERE phone = $1', [phone]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Ce numéro est déjà utilisé' });
    }

    const id = uuid();
    const hashed = await bcrypt.hash(password, 10);
    const uniqueId = generateUniqueId(name);
    const referralCode = generateReferralCode(name);

    await query(
      `INSERT INTO profiles (id, phone, name, role, unique_id, referral_code, balance, rating, completed_missions, is_online)
       VALUES ($1, $2, $3, $4, $5, $6, 25000, 4.5, 0, true)`,
      [id, phone, name, role || 'collecteur', uniqueId, referralCode]
    );

    const token = jwt.sign({ id, phone, name }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    res.status(201).json({
      token,
      user: { id, phone, name, role: role || 'collecteur', uniqueId, balance: 25000, rating: 4.5, completedMissions: 0, referralCode },
    });
  } catch (err) {
    console.error('register error:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    if (!phone || !password) {
      return res.status(400).json({ error: 'Champs requis: phone, password' });
    }

    const result = await query('SELECT * FROM profiles WHERE phone = $1', [phone]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    const user = result.rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    const token = jwt.sign({ id: user.id, phone: user.phone, name: user.name }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

    res.json({
      token,
      user: {
        id: user.id, phone: user.phone, name: user.name, role: user.role,
        uniqueId: user.unique_id, balance: parseFloat(user.balance),
        rating: parseFloat(user.rating), completedMissions: user.completed_missions,
        photoUrl: user.photo_url, referralCode: user.referral_code,
        points: user.points || 5,
      },
    });
  } catch (err) {
    console.error('login error:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/auth/me
router.get('/me', auth, async (req, res) => {
  try {
    const result = await query('SELECT * FROM profiles WHERE id = $1', [req.user.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Utilisateur introuvable' });
    const u = result.rows[0];
    res.json({
      id: u.id, phone: u.phone, name: u.name, role: u.role,
      uniqueId: u.unique_id, balance: parseFloat(u.balance),
      rating: parseFloat(u.rating), completedMissions: u.completed_missions,
      photoUrl: u.photo_url, latitude: u.latitude, longitude: u.longitude,
      collectedTypes: u.collected_types, referralCode: u.referral_code,
      referredBy: u.referred_by, referralEarnings: parseFloat(u.referral_earnings || 0),
      points: u.points || 5, isOnline: u.is_online,
    });
  } catch (err) {
    console.error('me error:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// PUT /api/auth/profile
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, role, collectedTypes, photoUrl } = req.body;
    const fields = [];
    const vals = [];
    let i = 1;
    if (name) { fields.push(`name = $${i++}`); vals.push(name); }
    if (role) { fields.push(`role = $${i++}`); vals.push(role); }
    if (photoUrl) { fields.push(`photo_url = $${i++}`); vals.push(photoUrl); }
    if (collectedTypes) { fields.push(`collected_types = $${i++}`); vals.push(collectedTypes); }
    if (fields.length === 0) return res.status(400).json({ error: 'Aucun champ à mettre à jour' });
    vals.push(req.user.id);
    await query(`UPDATE profiles SET ${fields.join(', ')} WHERE id = $${i}`, vals);
    res.json({ ok: true });
  } catch (err) {
    console.error('profile update error:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/users — list all users (for market profiles)
router.get('/users', async (req, res) => {
  try {
    const result = await query(
      `SELECT id, phone, name, unique_id, role, balance, rating, completed_missions,
              photo_url, latitude, longitude, is_online, collected_types, points
       FROM profiles ORDER BY points + completed_missions * 10 DESC`
    );
    res.json(result.rows.map(u => ({
      id: u.id, phone: u.phone, name: u.name, uniqueId: u.unique_id,
      role: u.role, balance: parseFloat(u.balance), rating: parseFloat(u.rating),
      completedMissions: u.completed_missions, photoUrl: u.photo_url,
      latitude: u.latitude, longitude: u.longitude, isOnline: u.is_online,
      collectedTypes: u.collected_types, points: u.points || 5,
    })));
  } catch (err) {
    console.error('users error:', err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

export default router;
