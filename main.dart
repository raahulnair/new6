import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: "1:273851780558:android:9a1467b655abe5b64daf9f",
      projectId: "task-management-darsh",
      apiKey: 'AIzaSyCpIUyBbuueYDxem_pkU_ZwhFqC0vdxAcU',
      messagingSenderId: 'task-management-darsh',
    ),
  );
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system, // Automatically switch between light and dark mode
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Authentication'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmailRegistration()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text('Register', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmailLoginForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text('Log In', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthHandler {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.email;
    } catch (e) {
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.email;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? currentUser() {
    return _firebaseAuth.currentUser;
  }
}

class EmailRegistration extends StatefulWidget {
  @override
  _EmailRegistrationState createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
  final AuthHandler _authHandler = AuthHandler();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isRegistered = false;
  String? _registeredEmail;

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please provide an email address.';
    } else if (!email.endsWith('@gsu.com')) {
      return 'Email should end with @gsu.com';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please provide a password.';
    } else if (password.length < 6) {
      return 'Password needs to be at least 6 characters long.';
    }
    return null;
  }

  void _register() async {
    String? email = await _authHandler.register(
      _emailCtrl.text,
      _passwordCtrl.text,
    );
    setState(() {
      _isRegistered = email != null;
      _registeredEmail = email;
    });

    if (_isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskView(email: _registeredEmail!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create an Account')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: Text('Register', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              Center(
                child: Text(
                  _isRegistered 
                      ? 'Registration successful for $_registeredEmail' 
                      : 'Please fill the form to register.',
                  style: TextStyle(color: _isRegistered ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailLoginForm extends StatefulWidget {
  @override
  _EmailLoginFormState createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final AuthHandler _authHandler = AuthHandler();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isLoggedIn = false;
  String _userEmail = '';

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email.';
    } else if (!email.endsWith('@gsu.com')) {
      return 'Email should end with @gsu.com';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password.';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  void _login() async {
    String? email = await _authHandler.login(
      _emailCtrl.text,
      _passwordCtrl.text,
    );
    setState(() {
      _isLoggedIn = email != null;
      _userEmail = email ?? '';
    });

    if (_isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskView(email: _userEmail)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                child: Text('Log In', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              Center(
                child: Text(
                  _isLoggedIn 
                      ? 'Logged in successfully as $_userEmail' 
                      : 'Please log in to continue.',
                  style: TextStyle(color: _isLoggedIn ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskView extends StatefulWidget {
  final String email;

  TaskView({Key? key, required this.email}) : super(key: key);

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  TextEditingController _taskCtrl = TextEditingController();
  TextEditingController _dayCtrl = TextEditingController();
  TextEditingController _timeCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addNewTask() async {
    if (_taskCtrl.text.isEmpty || _dayCtrl.text.isEmpty || _timeCtrl.text.isEmpty) {
      return;
    }

    await _firestore.collection('tasks').add({
      'taskName': _taskCtrl.text,
      'assignedTo': widget.email,
      'finished': false,
      'day': _dayCtrl.text,
      'timeSlot': _timeCtrl.text,
    });

    _taskCtrl.clear();
    _dayCtrl.clear();
    _timeCtrl.clear();
  }

  void _removeTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void _toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'finished': !isCompleted,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskCtrl,
              decoration: InputDecoration(
                labelText: 'What is the task',
                labelStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _dayCtrl,
              decoration: InputDecoration(
                labelText: 'Enter the Day ',
                labelStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _timeCtrl,
              decoration: InputDecoration(
                labelText: 'Enter the Duration',
                labelStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _addNewTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('assignedTo', isEqualTo: widget.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks found.'));
                  }

                  var tasks = snapshot.data!.docs;
                  Map<String, Map<String, List<DocumentSnapshot>>> taskGroups = {};

                  for (var task in tasks) {
                    String day = task['day'];
                    String timeSlot = task['timeSlot'];

                    if (!taskGroups.containsKey(day)) {
                      taskGroups[day] = {};
                    }
                    if (!taskGroups[day]!.containsKey(timeSlot)) {
                      taskGroups[day]![timeSlot] = [];
                    }
                    taskGroups[day]![timeSlot]!.add(task);
                  }

                  return ListView.builder(
                    itemCount: taskGroups.keys.length,
                    itemBuilder: (context, index) {
                      String day = taskGroups.keys.elementAt(index);
                      var timeSlots = taskGroups[day]!;

                      return ExpansionTile(
                        title: Text(
                          day,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        children: timeSlots.keys.map((timeSlot) {
                          var timeTasks = timeSlots[timeSlot]!;
                          return ExpansionTile(
                            title: Text(
                              timeSlot,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            children: timeTasks.map((task) {
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                elevation: 4,
                                child: ListTile(
                                  title: Text(task['taskName'], style: TextStyle(fontWeight: FontWeight.w500)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: task['finished'] ?? false,
                                        onChanged: (value) {
                                          _toggleTaskCompletion(task.id, task['finished']);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _removeTask(task.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}