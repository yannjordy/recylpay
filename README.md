# RecycPay

Application de gestion des déchets et recyclage au Cameroun.

## 🚀 Déploiement

### Vercel (Frontend Web)

```bash
# Installer Vercel CLI
npm install -g vercel

# Déployer
vercel --prod
```

### Supabase (Backend)

1. Crée un projet sur https://supabase.com
2. Va dans l'éditeur SQL et colle le contenu de `supabase/schema.sql`
3. Copie l'URL du projet et la clé anon dans `lib/services/supabase_service.dart`

### Minikube (Kubernetes local)

```bash
# Démarrer Minikube
minikube start

# Builder l'image Docker
docker build -t recylpay-web .

# Charger dans Minikube
minikube image load recylpay-web

# Déployer
kubectl apply -f k8s/deployment.yaml

# Voir le service
minikube service recylpay-web-service
```

## 📱 Télécharger l'APK

Télécharge la dernière version de l'APK depuis GitHub Actions :

👉 [**Télécharger la dernière version APK**](https://github.com/yannjordy/recylpay/releases/latest)

Ou construis-la localement :

```bash
flutter build apk --release
```

> L'APK est automatiquement buildée sur chaque push vers `main` via GitHub Actions.

## 🌐 Build Web

```bash
flutter build web --no-tree-shake-icons
```
