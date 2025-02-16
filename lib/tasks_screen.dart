import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/task.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<MessageBubble> messageBubbles = [];
  String messageText = ''; // ✅ नये टास्क का नाम स्टोर करने के लिए

  // To load the saved tasks from SharedPreferences
  void retrieveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = prefs.getStringList('tasks') ?? [];
    List<String> taskStatusList = prefs.getStringList('taskStatus') ?? [];

    setState(
      () {
        messageBubbles = List.generate(taskList.length, (index) {
          return MessageBubble(
            name: taskList[index],
            isDone: taskStatusList[index] == 'true', // Load the task status
          );
        });
      },
    );
  }

  // To save the tasks to SharedPreferences
  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        messageBubbles.map((task) => task.name).whereType<String>().toList();
    List<String> taskStatusList =
        messageBubbles.map((task) => task.isDone ? 'true' : 'false').toList();

    prefs.setStringList('tasks', taskList);
    prefs.setStringList('taskStatus', taskStatusList); // Save status as well
  }

  void deleteTask(int index) {
    setState(() {
      messageBubbles.removeAt(index);
      saveTasks();
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveTasks(); // Load tasks when the screen is initialized
  }

  Widget buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Add Task',
              style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.w400,
                  fontSize: 30),
            ),
          ),
          SizedBox(
            width: 330,
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                messageText = value; // ✅ TextField से डेटा लेना
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 3),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                if (messageText.isNotEmpty) {
                  messageBubbles.add(MessageBubble(
                      name: messageText,
                      isDone: false)); // ✅ नया टास्क लिस्ट में ऐड करना
                  saveTasks();
                  messageText = ''; // ✅ Save tasks to SharedPreferences
                  Navigator.pop(context); // ✅ BottomSheet बंद करना
                }
              });
            },
            child: Container(
              height: 70,
              width: 330,
              color: Colors.lightBlueAccent,
              child: Center(
                child: Text(
                  'Add',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => buildBottomSheet(context),
          );
        },
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 25, left: 30, right: 30),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  size: 30,
                  Icons.list,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                'Todoey',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                '${messageBubbles.length} Tasks', // ✅ टास्क की संख्या अपडेट करना
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30))),
                child: ListView.builder(
                  itemCount:
                      messageBubbles.length, // ✅ `itemCount` देना ज़रूरी है
                  itemBuilder: (context, index) {
                    return ListTile(
                      onLongPress: () {
                        deleteTask(index);
                      },
                      contentPadding: index == 0
                          ? EdgeInsets.only(left: 30, right: 10, top: 35)
                          : EdgeInsets.only(left: 30, right: 10),
                      title: Text(
                        messageBubbles[index].name ?? '',
                        style: TextStyle(
                            decoration: messageBubbles[index].isDone
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      trailing: Checkbox(
                        activeColor: Colors.lightBlueAccent,
                        value: messageBubbles[index].isDone,
                        onChanged: (value) {
                          setState(() {
                            messageBubbles[index].isDone = value!;
                            saveTasks(); // ✅ Save the updated task status
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
