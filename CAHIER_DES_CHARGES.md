# Cahier des Charges — RecycPay

## 1. Présentation du projet

**RecycPay** est une plateforme de gestion et valorisation des déchets connectant les citoyens, les collecteurs, les livreurs et les entreprises de recyclage au Cameroun. L'application permet de gérer les collectes, suivre les missions, effectuer des transactions financières, et accumuler des points de fidélité.

### Objectifs
- Faciliter la collecte et le recyclage des déchets via une marketplace
- Offrir un système de paiement mobile intégré (Mobile Money)
- Gamifier l'engagement via un système de points et classement
- Créer un réseau de trieurs, ramasseurs et livreurs

---

## 2. Fonctionnalités

### 2.1 Authentification & Profil
- Inscription en 2 étapes (identifiants → profil)
- Upload photo de profil (galerie)
- Choix du rôle : Trieur / Ramasseur / Livreur
- Connexion persistante (SharedPreferences)
- Modification du profil (nom, rôle, photo, matériaux)

### 2.2 Marché (Market)
- Filtrer les déchets par catégorie (plastique, verre, métal, carton, etc.)
- Prix au kg par catégorie
- Estimation du revenu

### 2.3 Carte (Map)
- Visualisation des collecteurs, points de dépôt et dépôts sauvages
- Signalement de pollution (description, sévérité, photo)

### 2.4 Publications (Feed)
- Création de posts avec photos et types de déchets
- Fil d'actualité avec likes et commentaires
- Suppression de ses propres posts

### 2.5 Portefeuille (Wallet)
- Solde en FCFA + points de fidélité
- 3 onglets : Dépôt / Retrait / Paiement P2P
- Paiement entre utilisateurs via `@uniqueId` avec commission 2%
- Autocomplete destinataire avec debounce
- Historique des transactions avec badges (frais, type)
- Carte swipeable (argent / points)

### 2.6 Points & Fidélité
- Points gagnés par paiements (2–10 pts selon montant)
- Max 1000 points
- 5 niveaux : Bronze → Argent → Or → Platine → Diamant
- Barre de progression

### 2.7 Classement aux Enchères
- 3 classements : Trieurs / Ramasseurs / Livreurs
- Enchère en points pour être en tête
- Minimum requis : points du leader + 1
- Validation du solde avant enchère

### 2.8 Collecte
- Demande de collecte (catégorie, poids, photos, description)
- Calcul du revenu estimé
- Liste des collectes avec statut (pending → accepted → completed → paid)
- Annulation et validation du poids

### 2.9 Missions
- Missions disponibles avec 3 types : Collecte / Livraison / Tri
- Chaque mission a un créateur (profil visible)
- Photos des déchets + description obligatoire
- Galerie plein écran
- Accepter / Terminer une mission

### 2.10 Notifications
- Notifications en temps réel (Supabase Realtime)
- Notifications push (Web Push API — à venir)

### 2.11 Messagerie
- Conversations entre utilisateurs
- Messages en temps réel (Supabase Realtime)
- Seed de conversations de démonstration

### 2.12 Guide de Tri
- 10 catégories de déchets avec icônes
- Prix/kg et conseils de préparation

### 2.13 Parrainage
- Code de parrainage unique
- Bonus de 5 FCFA par filleul
- Tableau de bord des filleuls

### 2.14 Assistant IA (RecycBot)
- Mode dégradé local (12 réponses intégrées)
- Mode avancé via OpenRouter API (clé optionnelle)

### 2.15 Administration
- Backend Express 5 avec PostgreSQL
- CRUD utilisateurs, transactions, missions
- JWT pour l'authentification API

---

## 3. Architecture Technique

### 3.1 Frontend — Flutter Web (PWA)

**Langage : Dart 3.x**

```
recylpay/
├── lib/
│   ├── main.dart              # Point d'entrée, providers, routes
│   ├── models/                # Modèles de données (8 fichiers)
│   ├── providers/             # Providers (9 : Auth, Wallet, Map, Feed, Market, Collection, Mission, Ai, Ranking)
│   ├── screens/               # Écrans (16 screens)
│   ├── services/              # MockData, AiService, SupabaseService, NotificationService, ChatService
│   ├── theme/                 # AppTheme (dark glass-morphism)
│   ├── utils/                 # Constants, Extensions, Responsive
│   └── widgets/               # Composants réutilisables
├── web/
│   ├── index.html             # PWA avec service worker
│   └── manifest.json          # Manifest PWA (standalone, dark/green)
└── pubspec.yaml
```

**Dépendances principales :**
| Paquet | Rôle |
|--------|------|
| `provider` | State management |
| `flutter_map` + `latlong2` | Cartographie |
| `supabase_flutter` | Base de données en temps réel |
| `shared_preferences` | Persistance locale |
| `flutter_secure_storage` | Stockage sécurisé |
| `image_picker` | Upload photos |
| `dio` | Requêtes HTTP |
| `geolocator` | Géolocalisation |
| `google_fonts` | Typographie |
| `uuid` | Génération d'IDs |

### 3.2 Backend — Node.js / Express 5

**Langage : JavaScript (ESM)**

```
backend/
├── src/
│   ├── index.js              # Serveur Express 5
│   └── routes/               # wallet.js, auth.js, posts.js, tasks.js, companies.js, referrals.js
├── Dockerfile                # node:22-alpine
└── package.json
```

**Dépendances :** `express@5`, `pg` (PostgreSQL), `bcrypt`, `jsonwebtoken`, `cors`, `uuid`

### 3.3 Base de données — PostgreSQL

```
supabase/schema.sql  — 165 lignes
```

Tables : `profiles`, `transactions`, `missions`, `posts`, `comments`, `collections`, `pollution_reports`, `companies`, `notifications`, `conversations`, `messages`, `recycling_tips`

Avec Row-Level Security (RLS) et publication Realtime.

### 3.4 Infrastructure

- **Conteneurisation :** Docker (backend : `node:22-alpine`, PostgreSQL)
- **Orchestration :** Kubernetes (api-deployment.yaml 2 réplicas, ConfigMap, Secret, Ingress)
- **Base de données :** Supabase (PostgreSQL managé avec Realtime)

---

## 4. Langages de programmation

| Couche | Langage | Version |
|--------|---------|---------|
| Frontend | Dart | 3.12+ |
| Backend | JavaScript (Node.js) | 22 LTS |
| Base de données | SQL (PostgreSQL) | 15+ |
| Infrastructure | YAML (Docker/K8s) | — |

### Pourquoi Dart/Flutter ?

1. **Cross-platform natif** — Un seul codebase pour Web, Android, iOS, desktop. La PWA Flutter offre une expérience native dans le navigateur avec offline support.

2. **Productivité** — Hot reload, typage fort, écosystème riche. Flutter permet de construire des UI complexes (glass-morphism, animations, transitions) avec une courbe d'apprentissage faible.

3. **Performance** — Compilation AOT (Ahead-Of-Time) pour le web, rendering via Skia/CanvasKit. Pas de bridge JavaScript ↔ natif.

4. **PWA Ready** — Flutter web génère un manifeste et un service worker, permettant l'installation sur l'écran d'accueil et le fonctionnement hors-ligne partiel.

5. **Écosystème** — Provider (state management), flutter_map (cartes), supabase_flutter (realtime), shared_preferences (persistance).

### Pourquoi Node.js/Express ?

1. **Performance I/O** — Modèle asynchrone non-bloquant. Parfait pour des opérations de base de données et des API REST sans calcul lourd.

2. **Écosystème NPM** — Accès à des milliers de packages (pg, bcrypt, jsonwebtoken, cors).

3. **Même langage que le frontend (JavaScript)** — Moins de friction cognitive, possibilité de partager du code (validation, types).

4. **Déploiement facile** — Docker léger (alpine), démarrage rapide, faible consommation mémoire.

### Pourquoi PostgreSQL ?

1. **Fiabilité** — Base relationnelle mature avec transactions ACID, intégrité référentielle.

2. **Fonctionnalités avancées** — Extension uuid-ossp, tableaux (TEXT[]), déclencheurs, Row-Level Security.

3. **Supabase Realtime** — Publication des changements de tables via WebSocket, idéal pour les notifications et la messagerie en temps réel sans infrastructure supplémentaire.

4. **JSON natif** — Support des colonnes JSONB pour les données semi-structurées (métadonnées, préférences).

---

## 5. Diagramme de données (relationnel)

```
profiles (1) ──── (N) transactions
profiles (1) ──── (N) missions        (via creator_id / collector_id / deliverer_id / sorter_id)
profiles (1) ──── (N) posts
profiles (1) ──── (N) comments
profiles (1) ──── (N) collections
profiles (1) ──── (N) notifications
profiles (1) ──── (N) conversations   (via participant_1 / participant_2)
conversations (1) ──── (N) messages
profiles (1) ──── (N) pollution_reports
companies (1) ──── (N) transactions
```

---

## 6. Contraintes techniques

- **Pas de Firebase** — Les notifications et le temps réel utilisent uniquement Supabase Realtime
- **Commission 2%** — Déduite du montant reçu (invisible pour l'envoyeur)
- **Points fidélité** — Max 1000 points, niveaux Bronze/Argent/Or/Platine/Diamant
- **Classement aux enchères** — Basé sur les points dépensés (type Upwork Connects)
- **PWA** — L'application est accessible via navigateur avec installation possible sur l'écran d'accueil
- **Réseau** — Build APK impossible dans l'environnement de développement (dépendances Gradle non accessibles)

---

## 7. Sécurité

- Mots de passe hashés avec bcrypt
- Authentification JWT pour l'API REST
- Row-Level Security PostgreSQL (chaque utilisateur voit uniquement ses données)
- Stockage sécurisé des tokens (flutter_secure_storage)
- Validation des entrées côté client et serveur

---

## 8. Roadmap

### Phase 1 (Terminé)
- ✅ Architecture Flutter Web + backend Node.js
- ✅ Authentification, profil, portefeuille
- ✅ Marché, carte, publications
- ✅ Collecte, missions, messagerie
- ✅ Points de fidélité, classement aux enchères
- ✅ Guide de tri, parrainage, assistant IA

### Phase 2 (En cours)
- 🔄 Intégration API Mobile Money (Orange/MTN)
- 🔄 Déploiement Kubernetes (Minikube/Cloud)
- 🔄 Notifications push Web Push API
- 🔄 Remplacer MockData par Supabase

### Phase 3 (À venir)
- ⏳ Application Android/iOS native (même codebase Flutter)
- ⏳ Passerelle de paiement Stripe/PayPal
- ⏳ Dashboard analytics pour les entreprises
- ⏳ Marketplace B2B pour acheteurs de matières recyclées
- ⏳ Intelligence artificielle pour la reconnaissance de déchets par photo
