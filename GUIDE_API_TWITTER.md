# 🔑 Guide Complet : Obtenir les Clés API Twitter/X

Ce guide vous explique étape par étape comment obtenir vos clés API Twitter/X pour activer l'authentification dans votre application.

## 📋 Prérequis

- Un compte Twitter/X actif
- Un numéro de téléphone vérifié sur votre compte Twitter/X
- Une adresse email vérifiée

## 🚀 Étapes pour Obtenir les Clés API

### Étape 1 : Créer un Compte Développeur Twitter

1. **Allez sur le Portail Développeur Twitter**
   - Visitez : [https://developer.twitter.com/](https://developer.twitter.com/)
   - Cliquez sur **"Sign up"** ou **"Sign in"** en haut à droite

2. **Connectez-vous avec votre compte Twitter/X**
   - Utilisez votre compte Twitter/X existant
   - Si vous n'avez pas de compte, créez-en un d'abord sur [twitter.com](https://twitter.com)

3. **Créer un Compte Développeur**
   - Une fois connecté, vous serez redirigé vers le portail développeur
   - Si c'est votre première fois, vous devrez créer un compte développeur
   - Cliquez sur **"Apply for a developer account"** ou **"Get started"**
   - Remplissez le formulaire :
     - **Nom d'utilisateur** : Votre nom d'utilisateur Twitter
     - **Email** : Votre email (doit être vérifié)
     - **Numéro de téléphone** : Doit être vérifié sur votre compte Twitter
     - **Raison d'utilisation** : Sélectionnez "Making a bot" ou "Exploring the API"
     - Acceptez les conditions d'utilisation
   - Cliquez sur **"Submit application"**

4. **Vérification Email**
   - Twitter vous enverra un email de vérification
   - Cliquez sur le lien dans l'email pour vérifier votre compte
   - L'approbation peut prendre quelques minutes à quelques heures

### Étape 2 : Créer une Application

Une fois votre compte développeur approuvé :

1. **Accéder au Dashboard**
   - Allez sur [https://developer.twitter.com/en/portal/dashboard](https://developer.twitter.com/en/portal/dashboard)
   - Connectez-vous si nécessaire

2. **Créer un Projet**
   - Cliquez sur **"Create Project"** ou **"New Project"**
   - Remplissez les informations :
     - **Project name** : Par exemple "Flutter TP26 App"
     - **Use case** : Sélectionnez "Making a bot" ou "Exploring the API"
     - **Project description** : Description de votre projet
   - Cliquez sur **"Next"** puis **"Create Project"**

3. **Créer une Application dans le Projet**
   - Dans votre projet, cliquez sur **"Add App"** ou **"Create App"**
   - Choisissez un nom pour votre application, par exemple "flutter_tp26"
   - Cliquez sur **"Create"**

### Étape 3 : Obtenir les Clés API

1. **Accéder aux Clés et Tokens**
   - Dans votre projet, sélectionnez votre application
   - Allez dans l'onglet **"Keys and tokens"** (Clés et tokens)
   - Vous verrez plusieurs sections :

2. **API Key et API Secret Key (Consumer Keys)**
   - Dans la section **"Consumer Keys"**
   - Vous verrez :
     - **API Key** (aussi appelée Consumer Key)
     - **API Secret Key** (aussi appelée Consumer Secret)
   - Si elles ne sont pas visibles, cliquez sur **"Generate"** ou **"Regenerate"**
   - **⚠️ IMPORTANT** : Copiez ces clés immédiatement, vous ne pourrez plus voir le Secret Key après !

3. **Access Token et Secret (Optionnel pour OAuth)**
   - Pour l'authentification OAuth, vous pourriez avoir besoin de ces tokens
   - Mais pour notre cas avec Firebase, les Consumer Keys suffisent

### Étape 4 : Configurer les Permissions

1. **Vérifier les Permissions de l'App**
   - Allez dans l'onglet **"App settings"** ou **"Settings"**
   - Vérifiez que les **App permissions** sont configurées :
     - Pour l'authentification, **"Read and Write"** ou **"Read"** suffit
   - Si nécessaire, modifiez et enregistrez

2. **Configurer les Callback URLs**
   - Dans **"App settings"**, trouvez la section **"Callback URLs / Redirect URLs"**
   - Ajoutez l'URL de callback Firebase :
     ```
     https://YOUR-PROJECT-ID.firebaseapp.com/__/auth/handler
     ```
     - Remplacez `YOUR-PROJECT-ID` par l'ID de votre projet Firebase
     - Vous pouvez trouver cet ID dans Firebase Console > Project Settings
   - Cliquez sur **"Save"**

### Étape 5 : Configurer dans Firebase

1. **Activer Twitter dans Firebase Console**
   - Allez sur [Firebase Console](https://console.firebase.google.com/)
   - Sélectionnez votre projet
   - Allez dans **Authentication** > **Sign-in method**
   - Cliquez sur **Twitter**
   - Activez Twitter Sign-In
   - Collez votre **API Key** (Consumer Key)
   - Collez votre **API Secret Key** (Consumer Secret)
   - **Callback URL** : `https://YOUR-PROJECT-ID.firebaseapp.com/__/auth/handler`
   - Cliquez sur **"Enregistrer"**

### Étape 6 : Configurer dans l'Application Flutter

1. **Ouvrir le fichier de configuration**
   - Ouvrez `lib/config/api_config.dart`

2. **Remplacer les clés**
   ```dart
   static const String twitterApiKey = 'VOTRE_API_KEY_ICI';
   static const String twitterApiSecret = 'VOTRE_API_SECRET_ICI';
   ```

3. **Vérifier l'URI de redirection**
   ```dart
   static const String twitterRedirectURI = 'flutter_tp26://';
   ```

## 🔒 Sécurité

### ⚠️ Important : Ne Commitez JAMAIS vos Clés API

1. **Ajouter au .gitignore**
   - Assurez-vous que `lib/config/api_config.dart` n'est pas commité
   - Ou utilisez des variables d'environnement

2. **Alternative : Variables d'Environnement**
   - Créez un fichier `.env` (non commité)
   - Utilisez le package `flutter_dotenv` pour charger les variables

## 🐛 Problèmes Courants

### Erreur : "Invalid credentials"
- **Solution** : Vérifiez que les clés dans Firebase Console correspondent exactement à celles dans `api_config.dart`
- Vérifiez qu'il n'y a pas d'espaces avant/après les clés

### Erreur : "Redirect URI mismatch"
- **Solution** : 
  - Vérifiez que l'URI dans `api_config.dart` correspond à celui configuré dans Twitter Developer Portal
  - Vérifiez que l'URL de callback dans Firebase Console est correcte

### Erreur : "App not authorized"
- **Solution** : 
  - Vérifiez que les permissions de l'app sont correctement configurées
  - Vérifiez que le callback URL est bien configuré dans Twitter Developer Portal

### Compte Développeur Non Approuvé
- **Solution** : 
  - Attendez l'approbation (peut prendre jusqu'à 24h)
  - Vérifiez votre email pour des demandes d'informations supplémentaires
  - Assurez-vous que votre compte Twitter est vérifié (email + téléphone)

## 📝 Checklist Finale

Avant de tester, vérifiez :

- [ ] Compte développeur Twitter créé et approuvé
- [ ] Projet créé dans Twitter Developer Portal
- [ ] Application créée dans le projet
- [ ] API Key et API Secret Key copiées
- [ ] Callback URL configuré dans Twitter Developer Portal
- [ ] Twitter activé dans Firebase Console
- [ ] Clés API ajoutées dans Firebase Console
- [ ] Clés API ajoutées dans `lib/config/api_config.dart`
- [ ] URI de redirection configuré dans `api_config.dart`

## 🎯 Test

Une fois tout configuré :

1. Lancez l'application : `flutter run`
2. Cliquez sur "Continuer avec X"
3. Autorisez l'application dans Twitter
4. Vous devriez être connecté et redirigé vers le Menu

## 📚 Ressources Utiles

- [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard)
- [Documentation Twitter API](https://developer.twitter.com/en/docs)
- [Firebase Twitter Auth](https://firebase.google.com/docs/auth/android/twitter-login)
- [Guide Twitter OAuth](https://developer.twitter.com/en/docs/authentication/overview)

## 💡 Astuce

Si vous avez des problèmes, vérifiez les logs dans la console :
```bash
flutter run -v
```

Cela vous donnera plus de détails sur les erreurs d'authentification.

---

**Note** : Twitter a récemment changé son nom en "X", mais les APIs et le portail développeur utilisent encore souvent le nom "Twitter". Les deux fonctionnent de la même manière.


