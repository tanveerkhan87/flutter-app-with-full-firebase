import 'package:fb_app/ui/auth/login.dart';
import 'package:fb_app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';

import 'add_post.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // This ref points to the entire "Post" node (like the whole table)
  final DatabaseReference ref = FirebaseDatabase.instance.ref("Post");
  final TextEditingController searchFilter = TextEditingController();
  final TextEditingController editCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the current user. It's important to do this here.
    final User? user = auth.currentUser;


    // If for some reason there is no user, show a loading screen to prevent errors.
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // This is the query that filters the database.
    // It tells Firebase: "Only give me the children of 'Post'
    // where the 'user_id' field is equal to the current user's UID."
    final Query userPostsQuery = ref.orderByChild('user_id').equalTo(user.uid);

    // popScope used to out from the app
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        await SystemNavigator.pop(); // Close the app
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Posts"),
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
            )
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
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FirebaseAnimatedList(
                defaultChild: const Center(
                  child: Text("No posts yet. Add one!"),), // default value
                // We pass our filtered query
                // Now, the list will only build items that match the current user's ID.
                query: userPostsQuery,
                itemBuilder: (context, snapshot, animation, index) {
                  // It's safer to check if data exists before trying to access it
                  if (snapshot.value == null) {
                    return const SizedBox.shrink(); // Return empty widget if data is null
                  }
      
                  final postData = snapshot.value as Map;
                  final title = postData['title'].toString().toLowerCase();
                  final id = postData['id'].toString();
      
                  if (searchFilter.text.isEmpty || title.contains(searchFilter.text.toLowerCase())) {
                    return ListTile(
                      title: Text(postData['title'].toString()),
                      subtitle: Text(id),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                alertMydialog(snapshot.key, postData['title'].toString());
                              },
                              leading: const Icon(Icons.edit),
                              title: const Text("Edit"),
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                // Use the snapshot's key to delete the correct item.
                                ref.child(snapshot.key!).remove().then((_) {
                                  Utility().toastMessage("Post Deleted");
                                }).catchError((error) {
                                  Utility().toastMessage(error.toString());
                                });
                              },
                              leading: const Icon(Icons.delete),
                              title: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
      
      
            // OR USING  Stream Builder method TO GET(fitch) DATA FROM FIREBASE
      
      
            // Expanded(
            //   child: StreamBuilder(
            //     // 1. The stream now listens to your filtered query
            //     stream: userPostsQuery.onValue,
            //     builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            //
            //       // 2. Handle the loading state
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //
            //       // 3. Handle errors
            //       if (snapshot.hasError) {
            //         return Center(child: Text('Something went wrong: ${snapshot.error}'));
            //       }
            //
            //       // 4. Handle the case where there is no data for this user
            //       if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            //         return const Center(child: Text("No posts found. Add one!"));
            //       }
            //
            //       // 5. If we have data, process and display it
            //       else {
            //         // The data comes as a Map where keys are the unique post IDs
            //         Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
            //
            //         // Convert the map's entries into a List to use with ListView.builder
            //         // Using .entries is great because it gives you both the key and the value
            //         final postList = map.entries.toList();
            //
            //         return ListView.builder(
            //           itemCount: postList.length,
            //           itemBuilder: (context, index) {
            //
            //             // Get the unique post key (e.g., -NqXy... )
            //             final postKey = postList[index].key;
            //
            //             // Get the post data (a map with 'title', 'id', 'user_id')
            //             final postData = postList[index].value as Map;
            //
            //             final title = postData['title'].toString();
            //             final id = postData['id'].toString();
            //
            //             // Filter for search functionality (optional but good to keep)
            //             if (searchFilter.text.isEmpty || title.toLowerCase().contains(searchFilter.text.toLowerCase())) {
            //               return ListTile(
            //                 title: Text(title),
            //                 subtitle: Text("ID: $id"),
            //                 trailing: PopupMenuButton(
            //                   icon: const Icon(Icons.more_vert),
            //                   itemBuilder: (context) => [
            //                     PopupMenuItem(
            //                       value: 1,
            //                       onTap: () {
            //                         // Use the postKey to know which item to edit
            //                         alertMydialog(postKey, title);
            //                       },
            //                       child: const ListTile(
            //                         leading: Icon(Icons.edit),
            //                         title: Text("Edit"),
            //                       ),
            //                     ),
            //                     PopupMenuItem(
            //                       value: 2,
            //                       onTap: () {
            //                         // Use the postKey to know which item to delete
            //                         ref.child(postKey).remove();
            //                       },
            //                       child: const ListTile(
            //                         leading: Icon(Icons.delete),
            //                         title: Text("Delete"),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               );
            //             } else {
            //               return Container(); // Hide if it doesn't match search
            //             }
            //           },
            //         );
            //       }
            //     },
            //   ),
            // ),
      
      
      
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPost()));
          },
        ),
      ),
    );
  }

  Future<void> alertMydialog(String? key, String title) async {
    editCont.text = title;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Post"),
          content: TextFormField(
            controller: editCont,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Update the post title using its unique key
                ref.child(key!).update({
                  "title": editCont.text.trim(),
                }).then((_) {
                  Utility().toastMessage("Post Updated");
                }).catchError((error) {
                  Utility().toastMessage(error.toString());
                });
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
