import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TaskManagementScreen extends StatefulWidget {
  final String categoryid;

  const TaskManagementScreen({Key? key, required this.categoryid})
      : super(key: key);

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  List<QueryDocumentSnapshot> tasks = [];
  bool isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController taskTitleController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();

  Future<void> getTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryid)
          .collection("tasks")
          .orderBy("timestamp", descending: true)
          .get();

      tasks = querySnapshot.docs;
    } catch (e) {
      print("Error fetching tasks: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryid)
          .collection("tasks")
          .add({
        "title": title,
        "description": description,
        "timestamp": FieldValue.serverTimestamp(),
      });
      await getTasks();
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  Future<void> editTask(
      String taskId, String newTitle, String newDescription) async {
    try {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryid)
          .collection("tasks")
          .doc(taskId)
          .update({"title": newTitle, "description": newDescription});
      await getTasks();
    } catch (e) {
      print("Error editing task: $e");
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryid)
          .collection("tasks")
          .doc(taskId)
          .delete();

    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "No tasks added",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          await AwesomeDialog(
                            context: context,
                            dialogType: DialogType.question,
                            animType: AnimType.rightSlide,
                            title: 'Confirm Deletion',
                            desc: 'Are you sure you want to delete this task?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {
                              deleteTask(task.id);
                              setState(() {
                                tasks.removeAt(index);
                              });
                            },
                          ).show();
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrangeAccent,
                                Colors.orangeAccent,

                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              task["title"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              task["description"],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => showAddEditDialog(
                                taskId: task.id,
                                initialTitle: task["title"],
                                initialDescription: task["description"],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void showAddEditDialog(
      {String? taskId, String? initialTitle, String? initialDescription}) {
    taskTitleController.text = initialTitle ?? "";
    taskDescriptionController.text = initialDescription ?? "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskId == null ? "Add Task" : "Edit Task"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: taskTitleController,
                  decoration:
                      const InputDecoration(hintText: "Enter task title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Task title cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: taskDescriptionController,
                  decoration:
                      const InputDecoration(hintText: "Enter task description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Task description cannot be empty";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (taskId == null) {
                    await addTask(taskTitleController.text,
                        taskDescriptionController.text);
                  } else {
                    await editTask(taskId, taskTitleController.text,
                        taskDescriptionController.text);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
