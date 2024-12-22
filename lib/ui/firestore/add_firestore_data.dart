import 'package:firebase_auth/firebase_auth.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:flutter/material.dart';
import '../../widgets/round_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AddFirestoreDataScreen extends StatefulWidget {
  const AddFirestoreDataScreen({super.key});

  @override
  State<AddFirestoreDataScreen> createState() => _AddFirestoreDataScreenState();
}

class _AddFirestoreDataScreenState extends State<AddFirestoreDataScreen> {
  bool loading= false;
  final PostCon = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection("Users");
  final User? user = FirebaseAuth.instance.currentUser; // we declare this to help each user access there own data
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
            SizedBox(height: 33,),
            TextFormField(
                controller: PostCon,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "What is in your mind",
                  border: OutlineInputBorder(),
                )
            ),
            SizedBox(height: 55),
            RoundButton(
                loading: loading,
                title: "Add", onTap: (){
              setState(() {
                loading = true;
              });
              final id = DateTime.now().microsecondsSinceEpoch.toString();
              firestore.doc(id).set({
                "title" : PostCon.text.toString(),
                "id": id,
                "user_id": user?.uid // Associate the post with the current user's uid

              }).then((value){
                setState(() {
                  loading = false;
                });
                Utility().toastMessage("Added Successfully");
              }).onError((error ,stackStrace){
                setState(() {
                  loading = false;
                });
                Utility().toastMessage(error.toString());
              });

            })
          ],
        ),
      ),
    );
  }
}
