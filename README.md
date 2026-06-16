# RecycPay

Plateforme de gestion et valorisation des déchets au Cameroun.

**Frontend :** Flutter Web (PWA) · **Backend :** Node.js/Express 5 · **Base :** PostgreSQL (Supabase)

---

## Prérequis

- Flutter SDK ≥3.12
- Node.js ≥22
- Docker (optionnel, pour le backend)
- Supabase projet (URL + anon key)

## Installation

```bash
# Frontend
git clone https://github.com/yannjordy/recylpay.git
cd recylpay
flutter pub get
flutter build web --no-tree-shake-icons

# Backend
cd backend
npm install
npm run dev
```

## Configuration

Copier `.env.example` vers `.env` et renseigner :

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
OPENROUTER_API_KEY=...    # optionnel, IA RecycBot
JWT_SECRET=...
DATABASE_URL=postgres://...
```

## Déploiement

```bash
# Docker
docker compose up -d

# Kubernetes
kubectl apply -f k8s/
```

## Structure du projet

```
lib/
├── main.dart                    # Entry point + routes
├── models/                      # Data models
├── providers/                   # State management
├── screens/                     # UI screens
├── services/                    # API, mock data, notifications
├── theme/                       # Dark glass-morphism theme
├── utils/                       # Constants, helpers
└── widgets/                     # Reusable components

backend/
├── src/index.js                 # Express 5 server
└── src/routes/                  # API endpoints

supabase/schema.sql              # Full database schema
k8s/                             # Kubernetes manifests
```

## Build

```bash
flutter build web --no-tree-shake-icons  # PWA
flutter build apk                          # Android (nécessite réseau Gradle)
flutter build ios                          # iOS (nécessite macOS + Xcode)
```

## Licence

MIT
