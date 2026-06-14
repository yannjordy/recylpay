const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'recylpay-secret-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';

export { PORT, JWT_SECRET, JWT_EXPIRES_IN, CORS_ORIGIN };
