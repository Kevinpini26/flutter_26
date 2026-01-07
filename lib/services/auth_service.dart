import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';
import 'preferences_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configuration Google Sign-In avec les scopes nécessaires et serverClientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Le serverClientId est automatiquement lu depuis google-services.json
    // Mais on peut le spécifier explicitement si nécessaire
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(displayName);

        // Create user document in Firestore
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? email,
          displayName: displayName,
          photoURL: userCredential.user!.photoURL,
          authProvider: 'email',
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());

        // Save to SharedPreferences
        await PreferencesService.saveUserData(
          userId: userModel.uid,
          email: userModel.email,
          displayName: userModel.displayName,
          photoUrl: userModel.photoURL,
          authProvider: userModel.authProvider,
        );

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  // Sign in with email
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        UserModel userModel;
        if (userDoc.exists) {
          userModel = UserModel.fromMap(userDoc.data()!);
        } else {
          userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? email,
            displayName: userCredential.user!.displayName,
            photoURL: userCredential.user!.photoURL,
            authProvider: 'email',
          );
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toMap());
        }

        // Save to SharedPreferences
        await PreferencesService.saveUserData(
          userId: userModel.uid,
          email: userModel.email,
          displayName: userModel.displayName,
          photoUrl: userModel.photoURL,
          authProvider: userModel.authProvider,
        );

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Méthode améliorée pour Google Sign-In
      GoogleSignInAccount? googleUser;
      
      // D'abord essayer signInSilently (si déjà connecté)
      googleUser = await _googleSignIn.signInSilently();
      
      // Si pas de session existante, demander une nouvelle connexion
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Vérifier que les tokens sont disponibles
      if (googleAuth.accessToken == null) {
        throw Exception(
          'Impossible d\'obtenir le token d\'accès Google.\n'
          'Vérifiez votre connexion internet et réessayez.',
        );
      }
      
      if (googleAuth.idToken == null) {
        throw Exception(
          'Impossible d\'obtenir le token ID Google.\n'
          'Vérifiez que Google Sign-In est bien activé dans Firebase Console.\n'
          'Assurez-vous que le SHA-1 est configuré dans Firebase Console.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? googleUser.email,
          displayName:
              userCredential.user!.displayName ?? googleUser.displayName,
          photoURL: userCredential.user!.photoURL ?? googleUser.photoUrl,
          authProvider: 'google',
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap(), SetOptions(merge: true));

        // Save to SharedPreferences
        await PreferencesService.saveUserData(
          userId: userModel.uid,
          email: userModel.email,
          displayName: userModel.displayName,
          photoUrl: userModel.photoURL,
          authProvider: userModel.authProvider,
        );

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur lors de la connexion Google';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'Un compte existe déjà avec un autre fournisseur d\'authentification';
          break;
        case 'invalid-credential':
          errorMessage =
              'Les identifiants fournis sont invalides. Vérifiez votre configuration Firebase.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'L\'authentification Google n\'est pas activée dans Firebase Console.\n'
              'Activez-la dans Authentication > Sign-in method > Google';
          break;
        case 'user-disabled':
          errorMessage = 'Ce compte utilisateur a été désactivé';
          break;
        case 'user-not-found':
          errorMessage = 'Aucun utilisateur trouvé avec ces identifiants';
          break;
        default:
          errorMessage =
              'Erreur Firebase: ${e.code} - ${e.message ?? "Erreur inconnue"}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Gérer les erreurs spécifiques de Google Sign-In
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('10') ||
          errorString.contains('developer_error')) {
        throw Exception(
          'Erreur de configuration Google Sign-In (Code 10).\n\n'
          'SOLUTION:\n'
          '1. Vérifiez que le SHA-1 est ajouté dans Firebase Console:\n'
          '   - Allez dans Project Settings > Your apps > Android app\n'
          '   - Ajoutez votre SHA-1 (debug et release si nécessaire)\n'
          '   - Pour obtenir le SHA-1 debug:\n'
          '     keytool -list -v -keystore "%USERPROFILE%\\.android\\debug.keystore" -alias androiddebugkey -storepass android -keypass android\n\n'
          '2. Vérifiez que google-services.json est dans android/app/\n'
          '3. Synchronisez le projet: flutter clean && flutter pub get',
        );
      } else if (errorString.contains('12500') ||
          errorString.contains('internal_error')) {
        throw Exception(
          'Erreur interne Google Sign-In (Code 12500).\n\n'
          'SOLUTION:\n'
          '1. Vérifiez que Google Sign-In est activé dans Firebase Console\n'
          '2. Vérifiez que le SHA-1 est correctement configuré\n'
          '3. Attendez quelques minutes après avoir ajouté le SHA-1\n'
          '4. Redémarrez l\'application',
        );
      } else if (errorString.contains('network')) {
        throw Exception('Erreur réseau. Vérifiez votre connexion internet.');
      } else {
        throw Exception('Erreur lors de la connexion Google: ${e.toString()}');
      }
    }
  }

  // Sign in with Twitter/X
  Future<UserModel?> signInWithTwitter() async {
    try {
      // Vérifier si les clés API sont configurées
      if (!ApiConfig.isTwitterConfigured) {
        throw Exception(
          'Les clés API Twitter ne sont pas configurées.\n'
          'Veuillez configurer vos clés dans lib/config/api_config.dart',
        );
      }

      final twitterLogin = TwitterLogin(
        apiKey: ApiConfig.twitterApiKey,
        apiSecretKey: ApiConfig.twitterApiSecret,
        redirectURI: ApiConfig.twitterRedirectURI,
      );

      final authResult = await twitterLogin.loginV2();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        if (authResult.authToken == null ||
            authResult.authTokenSecret == null) {
          throw Exception(
            'Impossible d\'obtenir les tokens d\'authentification Twitter',
          );
        }

        final credential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          final userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName:
                userCredential.user!.displayName ?? authResult.user?.name,
            photoURL:
                userCredential.user!.photoURL ??
                authResult.user?.thumbnailImage,
            authProvider: 'twitter',
          );

          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toMap(), SetOptions(merge: true));

          // Save to SharedPreferences
          await PreferencesService.saveUserData(
            userId: userModel.uid,
            email: userModel.email,
            displayName: userModel.displayName,
            photoUrl: userModel.photoURL,
            authProvider: userModel.authProvider,
          );

          return userModel;
        }
      } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
        // L'utilisateur a annulé la connexion
        return null;
      } else {
        throw Exception(
          'Échec de la connexion Twitter: ${authResult.errorMessage ?? "Erreur inconnue"}',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur lors de la connexion Twitter';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'Un compte existe déjà avec un autre fournisseur d\'authentification';
          break;
        case 'invalid-credential':
          errorMessage = 'Les identifiants fournis sont invalides';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'L\'authentification Twitter n\'est pas activée dans Firebase';
          break;
        case 'user-disabled':
          errorMessage = 'Ce compte utilisateur a été désactivé';
          break;
        default:
          errorMessage = 'Erreur: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erreur lors de la connexion Twitter: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await PreferencesService.clearUserData();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }
}
