import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/firebase_services/storage.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/shared/snackbar.dart';

class AuthMethods {
  register({
    required email,
    required password,
    required context,
    required title,
    required username,
    required imgName,
    required imgPath,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String url = await getImgURL(imgName: imgName, imgPath: imgPath, folderName: 'profileIMG');

// firebase firestore (Database)
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      UserDate user = UserDate(
          email: email,
          password: password,
          title: title,
          username: username,
          profileImg: url,
          uid: credential.user!.uid,
          followers: [],
          following: []);

      users
          .doc(credential.user!.uid)
          .set(user.convert2Map())
          .then((value) => showSnackBar(context,"User Added"))
          .catchError((error) => showSnackBar(context,"Failed to add user: $error"));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      showSnackBar(context,e.toString());
    }
  }

  signIn({required email, required password, required context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      showSnackBar(context,e.toString());
    }
  }

  // functoin to get user details from Firestore (Database)
  Future<UserDate> getUserDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return UserDate.convertSnap2Model(snap);
  }
}
