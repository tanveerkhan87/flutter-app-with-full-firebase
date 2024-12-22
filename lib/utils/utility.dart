import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Utility{
  void toastMessage(String Message){
    Fluttertoast.showToast(msg: Message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        fontSize: 16
    );
}

}