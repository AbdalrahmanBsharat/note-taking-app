// ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'TaskManagementScreen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("categories")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.of(context).pushNamed("addcategory");
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('Home Page'),
          actions: [
            IconButton(
                onPressed: () async {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  googleSignIn.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    "login",
                    (route) => false,
                  );
                },
                icon: Icon(Icons.exit_to_app))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : data.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No categories added",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, mainAxisExtent: 160),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.rightSlide,
                              title: 'Delete the Category',
                              desc:
                                  'Are you sure you want to delete this Category ',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                await FirebaseFirestore.instance
                                    .collection("categories")
                                    .doc(data[index].id)
                                    .delete();
                                setState(() {
                                  data.removeAt(index);
                                });
                              },
                            ).show();
                          },
                          onTap: () {
                            final categoryId = data[index].id;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskManagementScreen(
                                    categoryid: categoryId),
                              ),
                            );
                          },
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "images/folder.png",
                                    height: 100,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${data[index]['name'].substring(0, 1).toUpperCase() + "${data[index]['name']}".substring(1).toLowerCase()}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ));
  }
}
