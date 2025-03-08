import 'dart:developer';
import 'package:chat_app_cli/widgets/user_image.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _isLogin = true;

  //var _emailValue = '';
  final TextEditingController _emailController = TextEditingController();
  //var _passwordValue = '';
  final TextEditingController _passwordController = TextEditingController();

  void _submit() async{
    final valid = _formKey.currentState!.validate();

    if (!valid) return;

    //for controller:
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        final UserCredential userCredential = await _firebase.signInWithEmailAndPassword( //in firebase =http req.
          email: email,
          password: password,
        );
        print('User logged in: ${userCredential.user?.email}');
      }else{
          final UserCredential userCredential = await _firebase.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('User signed up: ${userCredential.user?.email}');
      }
    }on FirebaseAuthException catch (e) {
        //show e.msg as snack bar:
         ScaffoldMessenger.of(context).clearSnackBars();
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentecation Failed'),)
         );
        }

     _formKey.currentState!.save();
    //  log(_emailValue); 
    //  log(_passwordValue); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  right: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if(!_isLogin)
                          UserImagePicker(),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText:'Email Address' 
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            // onSaved: (value)=> _emailValue = value!,
                            //Firebase have regularExpression
                            validator: (value) {
                              if(value == null || value.trim().isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText:'Password' 
                            ),
                            obscureText: true,
                            // onSaved: (value)=> _passwordValue = value!,
                            validator: (value) {
                              if(value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 charachters long.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12,),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup')
                          ),
                          SizedBox(height: 5,),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = ! _isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                              ? 'Create an account'
                              : 'I already have an account')
                          )
                        ],
                      )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}