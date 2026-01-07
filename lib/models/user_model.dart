class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String authProvider; // 'email', 'google', 'twitter'

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.authProvider,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'authProvider': authProvider,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      authProvider: map['authProvider'] ?? 'email',
    );
  }
}

