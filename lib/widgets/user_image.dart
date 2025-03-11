import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File pickedImage, XFile originalFile) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
    XFile? _pickedImageOrignalFile;

  void _pickImage() async{
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
      imageQuality: 50,
    );
    if (pickedImage == null) {
      // pickedImage.readAsBytes();
      return Future.value();
    }
     setState(() {
      _pickedImageOrignalFile = pickedImage;
       _pickedImageFile = File(pickedImage.path);
     });
     widget.onPickedImage(_pickedImageFile!, _pickedImageOrignalFile!);
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickedImageFile == null ? null : FileImage(_pickedImageFile!),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Add Image',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ))
      ],
    );
  }
}