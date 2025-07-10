import 'package:fb_app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final PostCon = TextEditingController();
  // This ref points to the "Post" node, where all posts will be stored.
  final DatabaseReference databaseref = FirebaseDatabase.instance.ref("Post");
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            const SizedBox(height: 33),
            TextFormField(
              controller: PostCon,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What is in your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 55),
            RoundButton(
              loading: loading,
              title: "Add",
              onTap: () {
                addPost();
              },
            )
          ],
        ),
      ),
    );
  }

  void addPost() {
    setState(() {
      loading = true;
    });

    final User? user = auth.currentUser;
    if (user == null) {
      Utility().toastMessage("User not logged in!");
      setState(() {
        loading = false;
      });
      return;
    }


    // Use .push() to generate a unique, chronologically-sortable key for the new post.
    // This is the standard Firebase way .
    final newPostRef = databaseref.push();
    final String postId = newPostRef.key!; // This is the unique ID.

    // Now we set the data at this new, unique location.
    newPostRef.set({
      'id': postId, // Store the unique ID within the post data itself.
      'title': PostCon.text.toString(),
      'user_id': user.uid, // Store the user's ID with the post ***
    }).then((value) {
      Utility().toastMessage("Post Added");
      setState(() {
        loading = false;
      });
      Navigator.pop(context); // Go back to the previous screen after adding
    }).onError((error, stackTrace) {
      Utility().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    PostCon.dispose();
    super.dispose();
  }
}
