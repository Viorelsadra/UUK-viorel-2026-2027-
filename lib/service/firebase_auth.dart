import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
    String foto = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;
    if (user != null) {
      await _firestoreService.saveUser(
        uid: user.uid,
        name: name,
        email: email,
        kelas: kelas,
        foto: foto,
      );
    }
    return user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}