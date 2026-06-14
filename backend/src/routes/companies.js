import { Router } from 'express';
import { query } from '../config/db.js';

const router = Router();

// GET /api/companies
router.get('/', async (req, res) => {
  try {
    const result = await query('SELECT * FROM companies ORDER BY name');
    res.json(result.rows.map(c => ({
      id: c.id, name: c.name, description: c.description, phone: c.phone,
      email: c.email, website: c.website, city: c.city, address: c.address,
      latitude: c.latitude, longitude: c.longitude,
      rating: parseFloat(c.rating), hours: c.opening_hours,
      logoUrl: c.logo_url,
      materials: c.materials || [],
      services: c.services || [],
    })));
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

export default router;
