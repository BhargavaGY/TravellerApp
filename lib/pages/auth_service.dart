
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  // google sign in
  signInWithGoogle() async{
    final  GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    final user = FirebaseAuth.instance.currentUser;
    var querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: user?.email).get();
    if (!querySnapshot.docs.isNotEmpty){
      FirebaseFirestore.instance.collection('users').add({'email': user?.email});
    }

  }
}