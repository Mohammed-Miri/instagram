import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/firebase_services/storage.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/shared/snackbar.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  uploadPost(
      {required imgName,
      required imgPath,
      required description,
      required profileImg,
      required username,
      required context}) async {
    try {

      String url = await getImgURL(
          imgName: imgName,
          imgPath: imgPath,
          folderName: 'imgPosts/${FirebaseAuth.instance.currentUser!.uid}');

// firebase firestore (Database)
      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');

      String newId = const Uuid().v1();

      PostData post = PostData(
          datePublished: DateTime.now(),
          description: description,
          imgPost: url,
          likes: [],
          profileImg: profileImg,
          postId: newId,
          uid: FirebaseAuth.instance.currentUser!.uid,
          username: username);
      posts
          .doc(newId)
          .set(post.convert2Map())
          .then((value) => showSnackBar(context, "posted successfully"))
          .catchError((error) => showSnackBar(context,"Failed to post: $error"));
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      showSnackBar(context,e.toString());
    }
  }

  uploadComment(
      {required commentText,
      required postId,
      required profileImg,
      required username,
      required uid}) async {
    if (commentText.isNotEmpty) {
      String commentId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .set({
        "profilePic": profileImg,
        "username": username,
        "textComment": commentText,
        "dataPublished": DateTime.now(),
        "uid": uid,
        "commentId": commentId
      });
    }
  }

  toggleLike({required Map postData,required BuildContext context}) async {
    try {
      if (postData["likes"].contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    } catch (e) {
      showSnackBar(context,e.toString());
    }
  }
}
