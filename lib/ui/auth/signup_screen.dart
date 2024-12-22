import 'package:fb_app/ui/auth/login.dart';
import 'package:fb_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/utility.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final EmailCont = TextEditingController();
  final PasswordCont = TextEditingController();
  final confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  FirebaseAuth _auth= FirebaseAuth.instance;

  @override
  void dispose() {
    EmailCont.dispose();
    PasswordCont.dispose();
    super.dispose();
  }
  void SignUp(){
    setState(() {
      loading = true;
    });
    _auth.createUserWithEmailAndPassword(
        email: EmailCont.text.toString(),
        password:PasswordCont.text.toString()).then((value){
      setState(() {
        loading = false;
      });
    }).onError((error,stacktrace){
      Utility().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: EmailCont,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: "Email",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter an email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: PasswordCont,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: "Password",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: confirmPassword,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: "Confirm Password",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value != PasswordCont.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },


              ),
              const SizedBox(height: 22),
              RoundButton(
                loading: loading,
                title: "SignUp",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                SignUp();
                Utility().toastMessage("Done");
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Login()));
                  }
                },
              ),

              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already Have An Account?"),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                      return Login();
                    }));

                  }, child: Text("Login"))
                ],
              )
            ],

          ),
        ),
      ),
    );
  }
  }
