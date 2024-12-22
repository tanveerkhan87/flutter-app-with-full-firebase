

import 'dart:ffi';

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

  // here we work for real time database firebase
  final PostCon = TextEditingController();
  final  databaseref= FirebaseDatabase.instance.ref("Post"); // we created ref i.e  post as table called it node in firebase
  bool loading= false;
  final User? user = FirebaseAuth.instance.currentUser; // we declare this to help each user access there own data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD Posts"),
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
              //1st we created ref then give specific time as unique id then we set data in table by key value
              String id = DateTime.now().millisecondsSinceEpoch.toString();//helps to handle delete update etc by same id
              // node ref  i.e post as table  and its  child id etc
              databaseref.child(id).set({
                "id" : (id),
                "title" : PostCon.text.toString(),
                'user_id': user!.uid, // Store the user ID with the post

              }).then((vaule){
                setState(() {
                  loading = false;
                });
                Utility().toastMessage("Post ADD");
              }).onError((error, stacktrace){
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
