import 'package:google_sign_in/google_sign_in.dart';

class SignInHelper {
  static List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

  static Future<void> signInSilently({
    required Function(GoogleSignInAccount?) onSignIn,
  }) async {
    _googleSignIn.onCurrentUserChanged.listen((
      GoogleSignInAccount? account,
    ) async {
      onSignIn(account);
    });

    await _googleSignIn.signInSilently();
  }

  static Future<void> handleSignOut() => _googleSignIn.disconnect();

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  static Future<GoogleSignInAccount?> signedIn() async {
    return await _googleSignIn.signIn();
  }
}
