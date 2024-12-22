import 'package:fb_app/ui/auth/signup_screen.dart';
import 'package:fb_app/ui/firestore/firestore_list_screen.dart';
import 'package:fb_app/ui/forgot_password.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:fb_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final EmailCont = TextEditingController();
  final PasswordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth= FirebaseAuth.instance;
    final loading = false;
  @override
  void dispose() {
    EmailCont.dispose();
    PasswordCont.dispose();
    super.dispose();
  }
  void login(){
    setState(() {
      loading!=true;
    });
    _auth.signInWithEmailAndPassword(
        email: EmailCont.text.toString(),
        password: PasswordCont.text.toString()).then((value){//then use one the first condition is correct then do it
        Utility().toastMessage(value.user!.email.toString());
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirestoreListScreen()));
    }).onError((error,stacktrace){//if get any errors then do it
      Utility().toastMessage(error.toString());
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Login"),
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
                obscureText: true,
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
              RoundButton(
                loading: loading,
                title: "Login",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                  login();
                  }
                },
              ),

            SizedBox(height: 15,),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                    return ForgotPassword();
                  }));
                }, child: Text("Forgot Password?")),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't Have An Account?"),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                      return SignUp();
                    }));
                  }, child: Text("SignUp"))
                ],
              ),

            ],

          ),
        ),
      ),
    );
  }
}
