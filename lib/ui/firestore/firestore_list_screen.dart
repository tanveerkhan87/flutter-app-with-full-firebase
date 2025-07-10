import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_app/ui/auth/login.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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

  // Reference to the "Users" collection for CRUD operations.
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  @override
  Widget build(BuildContext context) {
    //  Get the current user from FirebaseAuth. This is crucial.
    final User? user = auth.currentUser;

    //  If for some reason there is no user, show a loading screen or error.
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in. Please restart the app."),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (a,b)async{
        await SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Posts in firestore"),
          actions: [
            IconButton(
              onPressed: () {
                auth.signOut().then((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                }).catchError((error) {
                  Utility().toastMessage(error.toString());
                });
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: TextFormField(
                controller: searchFilter,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search my posts",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Filter the stream to get only posts from the current user.
                // We query for documents where 'user_id' matches the logged-in user's uid.
                stream: usersCollection
                    .where('user_id', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts found. Add one!"));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        // Use .data() to safely access fields, casting to a Map
                        var data = doc.data() as Map<String, dynamic>;
                        var title = data['title'].toString().toLowerCase();

                        // Filter posts based on the search query
                        if (searchFilter.text.isEmpty ||
                            title.contains(searchFilter.text.toLowerCase())) {
                          return ListTile(
                            title: Text(data['title']),
                            subtitle: Text("Post ID: ${doc.id}"), // Display the document ID
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: 1,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        showUpdateDialog(doc);
                                      },
                                      leading: const Icon(Icons.edit),
                                      title: const Text("Update"),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        usersCollection.doc(doc.id).delete();
                                        Utility().toastMessage("Deleted");
                                      },
                                      leading: const Icon(Icons.delete),
                                      title: const Text("Delete"),
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //  Pass the real user ID to the next screen
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddFirestoreDataScreen(userId: user.uid),
            ));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void showUpdateDialog(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    editController.text = data['title'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Post"),
          content: TextFormField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter new title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  usersCollection
                      .doc(doc.id)
                      .update({"title": editController.text.trim()}).then((_) {
                    Utility().toastMessage("Updated Successfully");
                    Navigator.pop(context);
                  }).catchError((error) {
                    Utility().toastMessage(error.toString());
                  });
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
