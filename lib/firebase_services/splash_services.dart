import 'dart:async';
import 'package:fb_app/ui/firestore/firestore_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fb_app/ui/auth/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashServices {
  void isLogin(BuildContext context) {
    final auth= FirebaseAuth.instance;
    final user = auth.currentUser;
if(user!=null){
  Timer(Duration(seconds: 3), ()=>
  Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context)=>FirestoreListScreen()))
  );
}else{
  Timer(Duration(seconds: 3),()=>
  Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context)=>Login())));}
    
}}
