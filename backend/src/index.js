import express from 'express';
import cors from 'cors';
import { PORT, CORS_ORIGIN } from './config/env.js';
import authRoutes from './routes/auth.js';
import walletRoutes from './routes/wallet.js';
import taskRoutes from './routes/tasks.js';
import postRoutes from './routes/posts.js';
import companyRoutes from './routes/companies.js';
import referralRoutes from './routes/referrals.js';

const app = express();

app.use(cors({ origin: CORS_ORIGIN }));
app.use(express.json());

// Health check
app.get('/api/health', (_, res) => res.json({ ok: true, timestamp: new Date().toISOString() }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/companies', companyRoutes);
app.use('/api/referrals', referralRoutes);

// 404
app.use((_, res) => res.status(404).json({ error: 'Route introuvable' }));

// Error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

app.listen(PORT, () => {
  console.log(`RecycPay API running on port ${PORT}`);
});

export default app;
