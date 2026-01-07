# Application Flutter - Gestion de Produits

Une application mobile moderne développée avec Flutter pour la gestion de produits avec authentification multi-providers et stockage Firestore.

## 👥 Équipe de Développement

Ce projet a été réalisé par :
- **PINI MPANZA KEVIN**
- **BUKASA SHIMATU JUNIOR**
- **MUKENDI MULU JOEL**
- **NGANDU KASHINDA FRANCK**
- **LOLONGA EPANDA ROGER**

## 📦 Dépôt GitHub

Dépôt disponible sur : [https://github.com/Kevinpini26/flutter_26.git](https://github.com/Kevinpini26/flutter_26.git)

## 🚀 Fonctionnalités

- **Authentification Multi-Providers**
  - Connexion/Inscription par email
  - Connexion avec Google
  - Connexion avec X (Twitter)
  - Utilisation de SharedPreferences pour la persistance de session

- **Gestion des Produits**
  - Ajouter des produits avec nom, description, prix et quantité
  - Lister tous les produits
  - Supprimer des produits
  - Interface moderne et intuitive

- **Base de Données**
  - Firestore pour le stockage des données
  - Collections: `users` et `products`
  - Synchronisation en temps réel

## 📋 Prérequis

- Flutter SDK (version 3.9.2 ou supérieure)
- Compte Firebase avec Firestore activé
- Compte Google Cloud pour l'authentification Google
- Compte Twitter Developer pour l'authentification X (optionnel)

## 🔧 Installation

1. **Cloner le projet**
   ```bash
   cd flutter_tp26
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configuration des clés API Twitter/X (Optionnel)**
   - Ouvrez `lib/config/api_config.dart`
   - Remplacez `YOUR_TWITTER_API_KEY` et `YOUR_TWITTER_API_SECRET` par vos clés API
   - Obtenez vos clés depuis [Twitter Developer Portal](https://developer.twitter.com/)

3. **Configuration Firebase**

   ### Android
   - Téléchargez le fichier `google-services.json` depuis la console Firebase
   - Placez-le dans `android/app/`
   - Ajoutez la classe Google Services dans `android/build.gradle`:
     ```gradle
     dependencies {
         classpath 'com.google.gms:google-services:4.4.0'
     }
     ```
   - Ajoutez le plugin dans `android/app/build.gradle`:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```

   ### iOS
   - Téléchargez le fichier `GoogleService-Info.plist` depuis la console Firebase
   - Placez-le dans `ios/Runner/`
   - Ouvrez `ios/Runner.xcworkspace` dans Xcode
   - Ajoutez le fichier au projet dans Xcode

4. **Configuration de l'authentification Twitter/X**

   **IMPORTANT**: Suivez le guide complet dans `CONFIGURATION_COMPLETE.md` pour configurer Google et Twitter/X à 100%.
   
   En résumé:
   - Configurez les clés API dans `lib/config/api_config.dart`
   - Activez Twitter dans Firebase Console
   - Configurez les URLs de callback

5. **Configuration Firebase Console**

   - Activez l'authentification par email/mot de passe
   - Activez l'authentification Google
   - Activez l'authentification Twitter (si vous utilisez X)
   - Créez les collections Firestore:
     - `users` (sera créée automatiquement)
     - `products` (sera créée automatiquement)

## 🏃 Exécution

```bash
flutter run
```

## 📱 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/
│   ├── user_model.dart      # Modèle utilisateur
│   └── product_model.dart   # Modèle produit
├── services/
│   ├── auth_service.dart    # Service d'authentification
│   ├── product_service.dart # Service de gestion des produits
│   └── preferences_service.dart # Service SharedPreferences
└── screens/
    ├── login_screen.dart    # Page de connexion
    ├── signup_screen.dart   # Page d'inscription
    └── menu_screen.dart     # Page principale avec gestion des produits
```

## 🎨 Design

L'application utilise un design moderne avec:
- Material Design 3
- Couleur principale: Indigo (#6366F1)
- Interface intuitive et responsive
- Animations fluides

## 📝 Collections Firestore

### Collection `users`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "authProvider": "email|google|twitter"
}
```

### Collection `products`
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "quantity": "number",
  "imageUrl": "string (optionnel)",
  "userId": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🔐 Sécurité

- Les mots de passe sont gérés par Firebase Authentication
- Les données utilisateur sont stockées de manière sécurisée
- Les règles Firestore doivent être configurées pour la sécurité

### Exemple de règles Firestore (à configurer dans Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## 🐛 Dépannage

### Erreur: "Firebase not initialized"
- Vérifiez que vous avez bien ajouté les fichiers de configuration Firebase
- Vérifiez que `Firebase.initializeApp()` est appelé dans `main.dart`

### Erreur: "Google Sign In failed"
- Vérifiez que l'authentification Google est activée dans Firebase Console
- Vérifiez que le SHA-1 de votre application est ajouté dans Firebase Console

### Erreur: "Twitter Sign In failed"
- Vérifiez que vous avez bien configuré les clés API Twitter
- Vérifiez que l'authentification Twitter est activée dans Firebase Console

## 📄 Licence

Ce projet est créé à des fins éducatives.

## 👨‍💻 Auteur

Développé avec Flutter pour le TP26
