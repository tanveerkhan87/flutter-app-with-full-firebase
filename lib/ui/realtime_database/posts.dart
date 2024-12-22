import 'package:fb_app/ui/auth/login.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:fb_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'add_post.dart';
//real time data base
class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> { 
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("Post");//with ref here post represent as a table we call it node
  final TextEditingController searchFilter = TextEditingController();
  final TextEditingController editCont = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Query to fetch posts where user_id matches current user's uid
    final Query userPostsQuery = ref.orderByChild('user_id').equalTo(user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
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
          )
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
            child: FirebaseAnimatedList(
              defaultChild: const Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
              query: userPostsQuery,
              itemBuilder: (context, snapshot, animation, index) {
                // Extract title and id from snapshot data
                final title = snapshot.child("title").value.toString().toLowerCase();
                final id = snapshot.child("id").value.toString();

                // Check if search filter is empty or matches post title
                if (searchFilter.text.isEmpty || title.contains(searchFilter.text.toLowerCase())) {
                  return ListTile(
                    title: Text(title),
                    subtitle: Text(id),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        // Edit post option
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              alertMydialog(snapshot.key, snapshot.child("title").value.toString());
                            },
                            leading: Icon(Icons.edit),
                            title: Text("Edit"),
                          ),
                        ),
                         // Delete post option
                        PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              // Remove post from Firebase
                              ref.child(snapshot.key!).remove().then((_) {
                                Utility().toastMessage("Post Deleted");
                              }).catchError((error) {
                                Utility().toastMessage(error.toString());
                              });
                            },
                            leading: Icon(Icons.delete),
                            title: Text("Delete"),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // If search filter doesn't match, return an empty container
                  return Container();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: RoundButton(
              title: "Add Post",
              onTap: () {
                // Navigate to add post screen
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPost()));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to show dialog for editing post
  Future<void> alertMydialog(String? id, String title) async {
    // Set initial text for edit controller
    editCont.text = title;

    // Show dialog for editing post title
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update"),
          content: TextFormField(
            controller: editCont,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Update post title in Firebase
                ref.child(id!).update({
                  "title": editCont.text,
                }).then((_) {
                  Utility().toastMessage("Post Updated");
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

// most of the time use this
// firebase second approach fitch data from server i.e firebase using stream builder
//         Expanded(
//           child: StreamBuilder(
//             stream:ref.onValue,
//               builder: (context ,AsyncSnapshot<DatabaseEvent>snapshot){
//               if(!snapshot.hasData){
//                 return CircularProgressIndicator();
//               }else{
//                 Map<dynamic, dynamic> map=snapshot.data!.snapshot.value as dynamic;
//                 List<dynamic> list=[];
//                   list.clear();
//                   list= map.values.toList();
//                 return ListView.builder(
//                     itemCount: snapshot.data!.snapshot.children.length,
//                     itemBuilder: (context ,index){
//                       return ListTile(
//                         title: Text(list[index]['title']),
//                         subtitle: Text(list[index]["id"]),
//                       );
//
//                     });
//               }
//
//               }),
//         ),



