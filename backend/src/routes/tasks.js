import { Router } from 'express';
import { v4 as uuid } from 'uuid';
import { query } from '../config/db.js';
import { auth } from '../middleware/auth.js';

const router = Router();

// POST /api/tasks/complete
router.post('/complete', auth, async (req, res) => {
  try {
    const { otherUserId, taskType } = req.body;
    if (!otherUserId || !taskType) return res.status(400).json({ error: 'Champs requis: otherUserId, taskType' });

    const pointsMap = { tri: 3, ramassage: 5, livraison: 4 };
    const points = pointsMap[taskType] || 2;

    await query('BEGIN');
    await query(
      'UPDATE profiles SET points = COALESCE(points, 5) + $1, completed_missions = completed_missions + 1 WHERE id = $2',
      [points, req.user.id]
    );
    await query(
      'UPDATE profiles SET points = COALESCE(points, 5) + $1, completed_missions = completed_missions + 1 WHERE id = $2',
      [points, otherUserId]
    );
    await query('COMMIT');

    res.json({ ok: true, pointsGained: points });
  } catch (err) {
    await query('ROLLBACK');
    console.error('task complete error:', err);
    res.status(500).json({ error: 'Erreur' });
  }
});

// POST /api/tasks/pay — in-app payment between users
router.post('/pay', auth, async (req, res) => {
  try {
    const { toUserId, amount, description } = req.body;
    if (!toUserId || !amount || amount <= 0) return res.status(400).json({ error: 'Montant invalide' });

    const senderRes = await query('SELECT balance FROM profiles WHERE id = $1', [req.user.id]);
    if (parseFloat(senderRes.rows[0].balance) < amount) {
      return res.status(400).json({ error: 'Solde insuffisant' });
    }

    const txId = uuid();
    await query('BEGIN');
    await query('UPDATE profiles SET balance = balance - $1 WHERE id = $2', [amount, req.user.id]);
    await query('UPDATE profiles SET balance = balance + $1 WHERE id = $2', [amount, toUserId]);
    await query(
      `INSERT INTO transactions (id, user_id, type, amount, status, description, reference)
       VALUES ($1, $2, 'payment', $3, 'completed', $4, $5)`,
      [uuid(), req.user.id, amount, description || 'Paiement in-app', `PAY-${Date.now()}`]
    );
    await query('COMMIT');

    res.json({ ok: true });
  } catch (err) {
    await query('ROLLBACK');
    console.error('pay error:', err);
    res.status(500).json({ error: 'Erreur lors du paiement' });
  }
});

export default router;
