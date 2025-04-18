import 'dart:io';
import 'dart:developer';
import 'package:enviroscan/api/apis.dart';
import 'package:enviroscan/helper/dialogs.dart';
import 'package:enviroscan/main.dart';
import 'package:enviroscan/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';




class LoginScreen extends StatefulWidget {

  

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500) ,() {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user != null){
        log('\nUser: ${user.user}');
        log('\nUseradditionalInfo: ${user.additionalUserInfo}');

        if(await APIS.userExists()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
        else{
          await APIS.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
        
      }  
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
  try{

    //To check if user is connected to internet or not 
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIS.auth.signInWithCredential(credential);
  }
  catch(e){
    log('\n_signInWithGoogle: $e');
  }

  Dialogs.showSnackBar(context, 'Something went wrong! (Check Internet)');

  return null;
} 
  
  @override
  Widget build(BuildContext context) {
    //mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviroscan'),
      ),

      body: Stack(children: [AnimatedPositioned(
        top: mq.height * .15, 
        width:mq.width * .5,  
        right: _isAnimate? mq.width * .25 : - mq.width * .25,
        duration: const Duration(milliseconds: 1000),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox.fromSize(
                size: const Size.fromRadius(100), // Image radius
                child: Image.asset('images/EnviroScan_logo1.png', fit: BoxFit.cover),
            ),
        )),
        Positioned(
        bottom: mq.height * .15, 
        width:mq.width * .9,  
        left: mq.width * .05,
        height: mq.height * .07,
        child: ElevatedButton.icon(onPressed: (){
         _handleGoogleBtnClick();
        }, 
        icon: Image.asset('images/google.png', height: mq.height * .03), label: RichText(text: const TextSpan(children: [
          TextSpan(text: 'Sign In with'),
          TextSpan(text: ' Google', style: TextStyle(fontWeight: FontWeight.w600))
        ],
        style: TextStyle(fontSize: 16))),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 0, 191, 51),
          shape: StadiumBorder()
        ), )
        )
        ],)

    );
  }
}