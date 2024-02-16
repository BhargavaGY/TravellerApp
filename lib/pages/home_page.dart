import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modernlogintute/pages/add_task.dart';
import 'package:modernlogintute/pages/delete_task.dart';
import 'package:modernlogintute/pages/navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final fireStore = FirebaseFirestore.instance;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  final CollectionReference taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot =
        await taskCollection.where('userID', isEqualTo: user?.uid).get();
    List<Map<String, dynamic>> dataList = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    dataList.sort((a, b) =>
        int.parse(b['taskPriority']).compareTo(int.parse(a['taskPriority'])));
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text(
          'Traveller',
          style: TextStyle(fontSize: 25),
        ),
        elevation: 0.0,
        backgroundColor: Colors.black,
        // actions: [
        //   IconButton(
        //     onPressed: signUserOut,
        //     icon: const Icon(Icons.logout),
        //   )
        // ],
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // height: 100,
                  width: double.infinity,
                  child: Text(
                    'Personal Checklist',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: fireStore
                      .collection('tasks')
                      .where('userID', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                              'No task available'); // Handle the case where data is null
                        } else {
                          List<Map<String, dynamic>>? data = snapshot.data;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data!.length,
                              itemBuilder: (context, index) {
                                if (data[index]['userID'] == user.uid) {
                                  return Container(
                                    height: 75,
                                    margin: const EdgeInsets.only(bottom: 15.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 5.0,
                                          offset: Offset(0,
                                              5), // shadow direction: bottom right
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0.0, 8, 0, 0),
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          alignment: Alignment.center,
                                          child: Checkbox(
                                            value: data[index]['isCompleted'],
                                            onChanged: (value) {
                                              setState(() {
                                                fireStore
                                                    .collection('tasks')
                                                    .doc(data[index]['id'])
                                                    .update(
                                                  {
                                                    'isCompleted': !data[index]
                                                        ['isCompleted']
                                                  },
                                                );
                                              });
                                            },
                                            activeColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        data[index]['taskName'] +
                                            '\n' +
                                            data[index]['taskPriority'],
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        data[index]['taskDesc'],
                                      ),
                                      // isThreeLine: true,
                                      dense: true,
                                      trailing: IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DeleteTaskDialog(
                                                  taskId: data[index]['id'],
                                                  taskName: data[index]
                                                      ['taskName']);
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          CupertinoIcons.delete_solid,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddTaskDialog();
                      },
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(
                        CupertinoIcons.add_circled_solid,
                        size: 30,
                        color: Colors.black,
                      ),
                      Text('Add Task', style: TextStyle(color: Colors.black)),
                    ],
                  )),
            ),
            // SizedBox(
            //   width: 10,
            // ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/sharedtasks', (route) => false);
                },
                child: const Column(
                  children: [
                    Icon(
                      CupertinoIcons.rectangle_stack_person_crop_fill,
                      size: 30,
                      color: Colors.black,
                    ),
                    Text(
                      'Shared Checklists',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
