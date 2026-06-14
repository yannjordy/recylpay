import { Router } from 'express';
import { v4 as uuid } from 'uuid';
import { query } from '../config/db.js';
import { auth, optionalAuth } from '../middleware/auth.js';

const router = Router();

// GET /api/posts
router.get('/', optionalAuth, async (req, res) => {
  try {
    const userId = req.user?.id;
    const result = await query(
      `SELECT p.*, u.name AS user_name, u.unique_id AS user_unique_id, u.photo_url AS user_photo_url
       FROM posts p JOIN profiles u ON p.user_id = u.id
       ORDER BY p.created_at DESC LIMIT 50`
    );
    res.json(result.rows.map(p => ({
      id: p.id, userId: p.user_id, userName: p.user_name,
      userUniqueId: p.user_unique_id, userPhotoUrl: p.user_photo_url,
      imageUrl: p.image_url, description: p.description,
      wasteTypes: p.waste_types, likes: p.likes,
      commentsCount: p.comments_count || 0,
      createdAt: p.created_at,
      isLiked: p.liked_by?.includes(userId) || false,
    })));
  } catch (err) {
    console.error('posts error:', err);
    res.status(500).json({ error: 'Erreur' });
  }
});

// GET /api/posts/user/:userId
router.get('/user/:userId', optionalAuth, async (req, res) => {
  try {
    const result = await query(
      `SELECT p.*, u.name AS user_name, u.unique_id AS user_unique_id, u.photo_url AS user_photo_url
       FROM posts p JOIN profiles u ON p.user_id = u.id
       WHERE p.user_id = $1 ORDER BY p.created_at DESC`,
      [req.params.userId]
    );
    res.json(result.rows.map(p => ({
      id: p.id, userId: p.user_id, userName: p.user_name,
      userUniqueId: p.user_unique_id, userPhotoUrl: p.user_photo_url,
      imageUrl: p.image_url, description: p.description,
      wasteTypes: p.waste_types, likes: p.likes,
      commentsCount: p.comments_count || 0,
      createdAt: p.created_at,
      isLiked: false,
    })));
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

// POST /api/posts
router.post('/', auth, async (req, res) => {
  try {
    const { imageUrl, description, wasteTypes } = req.body;
    if (!description) return res.status(400).json({ error: 'Description requise' });

    const id = uuid();
    await query(
      `INSERT INTO posts (id, user_id, image_url, description, waste_types)
       VALUES ($1, $2, $3, $4, $5)`,
      [id, req.user.id, imageUrl || null, description, wasteTypes || []]
    );
    res.status(201).json({ id, ok: true });
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

// POST /api/posts/:id/like
router.post('/:id/like', auth, async (req, res) => {
  try {
    await query(
      `UPDATE posts SET likes = likes + 1, liked_by = array_append(COALESCE(liked_by, '{}'), $1)
       WHERE id = $2 AND NOT (COALESCE(liked_by, '{}') @> ARRAY[$1])`,
      [req.user.id, req.params.id]
    );
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: 'Erreur' });
  }
});

export default router;
