import 'package:fb_app/ui/auth/login.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:fb_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_firestore_data.dart';

class FirestoreListScreen extends StatefulWidget {
  const FirestoreListScreen({super.key});

  @override
  State<FirestoreListScreen> createState() => _FirestoreListScreenState();
}

class _FirestoreListScreenState extends State<FirestoreListScreen> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController searchFilter = TextEditingController();
  final TextEditingController editController = TextEditingController();

// Stream of real-time snapshots from the "Users" collection in Firestore.
  final fireStore = FirebaseFirestore.instance.collection("Users").snapshots();
// Reference to the "Users" collection for CRUD operations.
  final usersCollection = FirebaseFirestore.instance.collection("Users");
// Current logged-in user from Firebase Authentication.
  final User? user = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore"),
        actions: [
          IconButton(
            onPressed: () {
              // Sign out user and navigate back to login screen
              auth.signOut().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }).catchError((error) {
                Utility().toastMessage(error.toString());
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: TextFormField(
              controller: searchFilter,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (String value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(height: 33),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // StreamBuilder listens to real-time updates from the Firestore query
              stream: usersCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Something went wrong");
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No posts found");
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      // or
                      //var title = snapshot.data!.docs[index]["title"].toString().toLowerCase();
                      //var id = snapshot.data!.docs[index]["id"].toString().toLowerCase();
                      // or below
                      var doc = snapshot.data!.docs[index];
                      var title = doc["title"].toString().toLowerCase();
                      var id = doc["id"].toString();

                      // Filter posts based on the search query
                      if (searchFilter.text.isEmpty || title.contains(searchFilter.text.toLowerCase())) {
                        return ListTile(
                         // or  title: Text(snapshot.data!.docs[index]["title"]), and below can also
                          title: Text(doc["title"]),
                          subtitle: Text(id),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (BuildContext context) {
                              return [
                                // Edit post option
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showUpdateDialog(doc);
                                    },
                                    leading: Icon(Icons.edit),
                                    title: Text("Update"),
                                  ),
                                ),
                                // Delete post option
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Remove post from Firestore
                                      usersCollection.doc(doc.id).delete().then((_) {
                                        Utility().toastMessage("Deleted Successfully");
                                      }).catchError((error) {
                                        Utility().toastMessage(error.toString());
                                      });
                                    },
                                    leading: Icon(Icons.delete),
                                    title: Text("Delete"),
                                  ),
                                ),
                              ];
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: RoundButton(
              title: "Add",
              onTap: () {
                // Navigate to add new data screen
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddFirestoreDataScreen(),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to show dialog for updating a post
  void showUpdateDialog(QueryDocumentSnapshot doc) {
    // Set initial text for edit controller
    editController.text = doc["title"];

    // Show dialog for editing post title
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update"),
          content: TextFormField(
            controller: editController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update post title in Firestore
                usersCollection.doc(doc.id).update({
                  "title": editController.text,
                }).then((_) {
                  Utility().toastMessage("Updated Successfully");
                  Navigator.pop(context);
                }).catchError((error) {
                  Utility().toastMessage(error.toString());
                });
              },
              child: Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
