import { Router } from 'express';
import { v4 as uuid } from 'uuid';
import { query } from '../config/db.js';
import { auth } from '../middleware/auth.js';

const router = Router();

// POST /api/wallet/deposit
router.post('/deposit', auth, async (req, res) => {
  try {
    const { amount, operator, phone } = req.body;
    if (!amount || amount <= 0) return res.status(400).json({ error: 'Montant invalide' });

    const commission = amount * 0.02;
    const netAmount = amount - commission;
    const txId = uuid();

    await query('BEGIN');
    // Update balance
    await query('UPDATE profiles SET balance = balance + $1 WHERE id = $2', [netAmount, req.user.id]);
    // Deposit transaction
    await query(
      `INSERT INTO transactions (id, user_id, type, amount, commission, status, description, operator, phone, reference)
       VALUES ($1, $2, 'deposit', $3, $4, 'completed', $5, $6, $7, $8)`,
      [txId, req.user.id, amount, commission, `Dépôt ${operator || 'Mobile Money'}`, operator || null, phone || null, `DEP-${Date.now()}`]
    );
    await query('COMMIT');

    const bal = await query('SELECT balance FROM profiles WHERE id = $1', [req.user.id]);
    res.json({ ok: true, balance: parseFloat(bal.rows[0].balance), commission, netAmount });
  } catch (err) {
    await query('ROLLBACK');
    console.error('deposit error:', err);
    res.status(500).json({ error: 'Erreur lors du dépôt' });
  }
});

// POST /api/wallet/withdraw
router.post('/withdraw', auth, async (req, res) => {
  try {
    const { amount, operator, phone } = req.body;
    if (!amount || amount <= 0) return res.status(400).json({ error: 'Montant invalide' });

    const userRes = await query('SELECT balance FROM profiles WHERE id = $1', [req.user.id]);
    const balance = parseFloat(userRes.rows[0].balance);
    if (balance < amount) return res.status(400).json({ error: 'Solde insuffisant' });

    const commission = amount * 0.02;
    const netAmount = amount - commission;
    const txId = uuid();

    await query('BEGIN');
    await query('UPDATE profiles SET balance = balance - $1 WHERE id = $2', [amount, req.user.id]);
    await query(
      `INSERT INTO transactions (id, user_id, type, amount, commission, status, description, operator, phone, reference)
       VALUES ($1, $2, 'withdrawal', $3, $4, 'completed', $5, $6, $7, $8)`,
      [txId, req.user.id, amount, commission, `Retrait ${operator || 'Mobile Money'}`, operator || null, phone || null, `WTH-${Date.now()}`]
    );
    await query('COMMIT');

    const bal = await query('SELECT balance FROM profiles WHERE id = $1', [req.user.id]);
    res.json({ ok: true, balance: parseFloat(bal.rows[0].balance), commission, netAmount });
  } catch (err) {
    await query('ROLLBACK');
    console.error('withdraw error:', err);
    res.status(500).json({ error: 'Erreur lors du retrait' });
  }
});

// GET /api/wallet/transactions
router.get('/transactions', auth, async (req, res) => {
  try {
    const result = await query(
      `SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC LIMIT 100`,
      [req.user.id]
    );
    res.json(result.rows.map(t => ({
      id: t.id, type: t.type, amount: parseFloat(t.amount),
      commission: t.commission ? parseFloat(t.commission) : null,
      status: t.status, operator: t.operator, phone: t.phone,
      description: t.description, reference: t.reference,
      createdAt: t.created_at,
    })));
  } catch (err) {
    console.error('transactions error:', err);
    res.status(500).json({ error: 'Erreur' });
  }
});

// GET /api/wallet/balance
router.get('/balance', auth, async (req, res) => {
  try {
    const result = await query('SELECT balance FROM profiles WHERE id = $1', [req.user.id]);
    res.json({ balance: parseFloat(result.rows[0].balance) });
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

export default router;
