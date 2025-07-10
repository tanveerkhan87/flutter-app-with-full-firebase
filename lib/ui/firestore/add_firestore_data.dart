import 'package:fb_app/utils/utility.dart';
import 'package:flutter/material.dart';
import '../../widgets/round_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFirestoreDataScreen extends StatefulWidget {
  final String userId; //  Get the userId from previous screen

  const AddFirestoreDataScreen({required this.userId, super.key});

  @override
  State<AddFirestoreDataScreen> createState() => _AddFirestoreDataScreenState();
}

class _AddFirestoreDataScreenState extends State<AddFirestoreDataScreen> {
  bool loading = false;
  final TextEditingController postController = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection("Users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Firestore Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            SizedBox(height: 33),
            TextFormField(
              controller: postController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What is in your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 55),
            RoundButton(
              loading: loading,
              title: "Add",
              onTap: () {
                setState(() { loading = true; });

                //  Add new post to Firestore and associate it with the current user
                firestore.add({
                  "title": postController.text.toString(),
                  "user_id": widget.userId, //  Save user ID to filter later
                }).then((_) {
                  setState(() { loading = false; });
                  Utility().toastMessage("Added Successfully");
                  Navigator.pop(context); //  Close screen after adding
                }).catchError((error) {
                  setState(() { loading = false; });
                  Utility().toastMessage(error.toString());
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
