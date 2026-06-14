import { Router } from 'express';
import { query } from '../config/db.js';
import { auth } from '../middleware/auth.js';

const router = Router();

// GET /api/referrals/stats
router.get('/stats', auth, async (req, res) => {
  try {
    const result = await query(
      `SELECT COUNT(*) AS count, COALESCE(SUM(balance * 0.05), 0) AS earnings
       FROM profiles WHERE referred_by = $1`,
      [req.user.id]
    );
    res.json({
      count: parseInt(result.rows[0].count),
      earnings: parseFloat(result.rows[0].earnings),
    });
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

// POST /api/referrals/register
router.post('/register', async (req, res) => {
  try {
    const { phone, name, password, referralCode } = req.body;
    if (!phone || !name || !password) {
      return res.status(400).json({ error: 'Champs requis' });
    }

    // Find referrer
    let referrerId = null;
    if (referralCode) {
      const ref = await query('SELECT id FROM profiles WHERE referral_code = $1', [referralCode]);
      if (ref.rows.length > 0) referrerId = ref.rows[0].id;
    }

    const id = uuidv4();
    const hashed = await bcrypt.hash(password, 10);
    const uid = `@${name.toLowerCase().replace(/[^a-z0-9]/g, '')}${Date.now().toString().slice(-4)}`;
    const rc = `${name.slice(0, 3).toUpperCase()}${Date.now().toString().slice(-3)}`;

    await query(
      `INSERT INTO profiles (id, phone, name, unique_id, referral_code, referred_by, balance, rating, is_online)
       VALUES ($1, $2, $3, $4, $5, $6, 25000, 4.5, true)`,
      [id, phone, name, uid, rc, referrerId]
    );

    res.status(201).json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

export default router;
