import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasetest/components/custombuttonauth.dart';
import 'package:firebasetest/components/customtextfieldadd.dart';
import 'package:flutter/material.dart';

import '../HomeScreen.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  Future<void> addCategory() {
    return categories
        .add({
          "name": name.text,
          "id": FirebaseAuth.instance.currentUser!.uid,
        })
        .then((value) => print("Category Added"))
        .catchError((error) => print("Failed to add Category: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category"),
        centerTitle: true,
      ),
      body: Form(
        key: formState,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                hinttext: "Enter Name",
                mycontroller: name,
                validator: (val) {
                  if (val == "") {
                    return "Can't be Empty";
                  }
                },
              ),
            ),
            CustomButtonAuth(
              title: "Add",
              onPressed: () {
                if (formState.currentState!.validate()) {
                  addCategory();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Homepage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
