import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({
    Key? key,
  }) : super(key: key);
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescController = TextEditingController();
  final TextEditingController taskTagController = TextEditingController();
  final TextEditingController taskPriorityController = TextEditingController();
  late String selectedValue = '';

  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');
  late List<dynamic> userList = [];

  _AddTaskDialogState(){
    fetchUserData();
  }

  fetchUserData() async {
    var querySnapshot =
    await userCollection.where('email', isNotEqualTo: user?.email).get();
    userList = querySnapshot.docs
        .map((doc) => doc.data())
        .toList();
    userList = userList.map((e) => e['email']).toList();
    userList.add('Self');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: const Text(
        'New Task',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: taskNameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Task',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.square_list,
                      color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: taskDescController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Description',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right,
                      color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: <Widget>[
                  const Icon(CupertinoIcons.person_3_fill, color: Colors.black),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      isExpanded: true,
                      hint: const Text(
                        'Collaborators',
                        style: TextStyle(fontSize: 14),
                      ),
                      validator: (value) => value == null
                          ? 'Please select the task tag' : null,
                      items: userList
                          .map(
                            (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (String? value) => setState(() {
                        if (value != null) selectedValue = value;
                        // print(selectedValue);
                      },
                      ),
                    ),
                  ),
                  // ElevatedButton(onPressed: ()=>fetchUserData(), child: Text('')),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: taskPriorityController,
                keyboardType: TextInputType.number,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Priority',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.sort_up, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final taskName = taskNameController.text;
            final taskDesc = taskDescController.text;
            final taskTag = selectedValue;
            final taskPriority = taskPriorityController.text;
            _addTasks(taskName: taskName, taskDesc: taskDesc, taskTag: taskTag,taskPriority: taskPriority, isCompleted : false);
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(Colors.black)
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future _addTasks(
      {required String taskName,
      required String taskDesc,
      required String taskTag,
      required String taskPriority,
      required bool isCompleted}) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('tasks').add(
      {
        'userID' : FirebaseAuth.instance.currentUser?.uid,
        'userEmail' : FirebaseAuth.instance.currentUser?.email,
        'taskName': taskName,
        'taskDesc': taskDesc,
        'taskTag': taskTag,
        'taskPriority': taskPriority,
        'isCompleted':isCompleted
      },
    );
    String taskId = docRef.id;
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update(
      {'id': taskId},
    );
    _clearAll();
  }

  void _clearAll() {
    taskNameController.text = '';
    taskDescController.text = '';
    taskTagController.text = '';
    taskPriorityController.text = '';
  }
}
