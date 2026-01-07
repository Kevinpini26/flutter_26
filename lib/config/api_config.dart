/// Configuration des clés API pour l'authentification
/// 
/// IMPORTANT: Remplacez les valeurs par vos propres clés API
/// Pour Twitter/X: https://developer.twitter.com/
/// 
/// GUIDE COMPLET: Voir GUIDE_API_TWITTER.md
class ApiConfig {
  // Configuration Twitter/X
  // Obtenez ces clés depuis https://developer.twitter.com/en/portal/dashboard
  // 
  // ÉTAPES:
  // 1. Créez un compte développeur sur https://developer.twitter.com/
  // 2. Créez un projet et une application
  // 3. Allez dans "Keys and tokens" de votre application
  // 4. Copiez l'API Key (Consumer Key) et l'API Secret Key (Consumer Secret)
  // 5. Collez-les ci-dessous
  static const String twitterApiKey = 'iP4L1BfItbYBNzIi3bNoI8571';
  static const String twitterApiSecret = 'qtN841RmAM6gR1DsEekTnddZziMqqo64ok1G5NYDXKTmwCzQjj';
  
  // URI de redirection pour Twitter/X
  // Doit correspondre à celui configuré dans Firebase Console et Twitter Developer Portal
  static const String twitterRedirectURI = 'flutter_tp26://';
  
  // Configuration Google Sign-In
  // Les clés sont automatiquement gérées par google-services.json
  // Assurez-vous que le SHA-1 est configuré dans Firebase Console
  
  /// Vérifie si les clés Twitter sont configurées
  static bool get isTwitterConfigured {
    return twitterApiKey != 'YOUR_TWITTER_API_KEY' &&
           twitterApiSecret != 'YOUR_TWITTER_API_SECRET' &&
           twitterApiKey.isNotEmpty &&
           twitterApiSecret.isNotEmpty;
  }
}

