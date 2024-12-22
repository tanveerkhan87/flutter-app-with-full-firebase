
import 'package:fb_app/utils/utility.dart';
import 'package:fb_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailCon= TextEditingController();
  final FirebaseAuth  auth = FirebaseAuth.instance;
   
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 28.0,vertical: 33),
            child: TextFormField(
              controller: emailCon,
              decoration:  InputDecoration(
                hintText: 'Plz Enter Current  Existing Email'
              )
            ),

          ),
          SizedBox(height: 22,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38.0),
            child: RoundButton(title: "Forgot", onTap: (){
            auth.sendPasswordResetEmail(email: emailCon.text.toString()).then((Value){
              Utility().toastMessage("WE Have Send You An Email Plz Check");
            }).onError((error ,stackTrace){
              Utility().toastMessage(error.toString());
            });
            }),
          )
        ],
      ),
    );
  }
}
