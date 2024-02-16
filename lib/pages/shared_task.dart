import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/navigation_bar.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  final user = FirebaseAuth.instance.currentUser!;
  final fireStore = FirebaseFirestore.instance;

  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('tasks');

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot = await _collection.where('taskTag',isEqualTo: user.email).get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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
                  child: const Text('Shared Checklist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: fireStore
                      .collection('tasks')
                      .where('taskTag', isEqualTo: user.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                              'No task available'); // Handle the case where data is null
                        } else {
                          List<Map<String, dynamic>>? data = snapshot.data;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data!.length,
                              itemBuilder: (context, index) {
                                  return Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 75.0,
                                        maxHeight: 100.0,
                                      ),
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
                                      // contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                        data[index]['taskName'] + '\n' + data[index]['userEmail'],
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        data[index]['taskDesc'],
                                      ),
                                      // isThreeLine: true,
                                      dense: true,
                                    ),
                                  );
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
        child: Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
            child: const Column(
              children: [
                Icon(
                  CupertinoIcons.square_list_fill,
                  size: 30,
                  color: Colors.black,
                ),
                Text(
                  'Personal Checklist',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
