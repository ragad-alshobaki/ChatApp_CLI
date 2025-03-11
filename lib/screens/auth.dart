import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
// import 'dart:html' as html;

import 'package:chat_app_cli/widgets/user_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _isLogin = true;

  final TextEditingController _uNameController = TextEditingController();
  //var _emailValue = '';
  final TextEditingController _emailController = TextEditingController();
  //var _passwordValue = '';
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage;
  XFile? _selectedOriginalFile;
  var _isUploading = false;

  //code to use cloudinary to upload image
  Future<String?> _uploadImageToCloudinary(File image) async {
    const cloudName = "drdlqu8mo";
    const apiKey = "477666213133877";
    const apiSecret = "N7h01-8dvia6_6eAy7FTyeVx4lI";
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = "ml_default";
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonData = json.decode(responseData);

    if (response.statusCode == 200) {
      return jsonData['secure_url'];
    } else {
      log("Failed to upload image: ${jsonData['error']['message']}");
      return null;
    }
  }

  void _submit() async{
    final valid = _formKey.currentState!.validate();

    if (!valid) return;
    if(!_isLogin && _selectedImage == null){
      return;
    }

    //for controller:
    final uName = _uNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      setState(() {
        _isUploading = true;
      });
      
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

        //in storage case
        // final Reference storageRef = FirebaseStorage.instance.ref().child('user_images')
        //   .child('${userCredential.user!.uid}.jpg');

        // await storageRef.putFile(_selectedImage!);
        // final imageUrl = await storageRef.getDownloadURL();
        // log(imageUrl);

        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await uploadBase64ToFirebase();
        }

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
          {
            // 'email': _emailValue.text,
            // 'password': _passwordValue.text,
            
            'username': uName,
            'email': email,
            'image_url': imageUrl ?? '',
          }
        );
      }
    }catch (e) {
        //show e.msg as snack bar:
         ScaffoldMessenger.of(context).clearSnackBars();
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()?? 'Authentecation Failed'),)
         );
        }

        setState(() {
        _isUploading = false;
      });

    //  _formKey.currentState!.save();      //on case use _emailValue & onSave fun.
    //  log(_emailValue); 
    //  log(_passwordValue); 
  }

 Future<String> uploadBase64ToFirebase() async {
  try {
    var bytes =  await _selectedOriginalFile?.readAsBytes() ?? Uint8List.fromList([]);
    var fileName = _selectedOriginalFile?.name ?? "";
    // Remove data URI prefix if present
   

    // Create a Blob object
    final blob = html.Blob(bytes);
    
    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child('uploads/$fileName');
    
    // Create upload metadata
    final metadata = SettableMetadata(
      contentType: 'image/jpeg', // Set appropriate content type
    );
    
    // Upload the file
    final uploadTask = fileRef.putBlob(blob, metadata);
    
    // Wait for upload to complete
    await uploadTask;
    
    // Get download URL
    final downloadUrl = await fileRef.getDownloadURL();
    
    return downloadUrl;
  } catch (e) {
    print('Error uploading base64 to Firebase: $e');
    throw e;
  }
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
                          UserImagePicker(onPickedImage: (File pickedImage, XFile originalFile) { 
                            _selectedImage = pickedImage;
                            _selectedOriginalFile = originalFile;
                           },),
                           if(!_isLogin)
                           TextFormField(
                            controller: _uNameController,
                            decoration: InputDecoration(
                              labelText:'User Name' 
                            ),
                            // onSaved: (value)=> _emailValue = value!,
                            //Firebase have regularExpression
                            validator: (value) {
                              if(value == null || value.trim().isEmpty) {
                                return 'Please enter your user name';
                              }
                              return null;
                            },
                          ),
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
                          if(!_isUploading)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup')
                          ),
                          SizedBox(height: 5,),
                          if(_isUploading)
                          CircularProgressIndicator(),
                          if(!_isUploading)
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