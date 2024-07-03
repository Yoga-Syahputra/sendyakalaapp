import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../models/progress_model.dart';
import 'dart:async';

class ActivitiesScreen extends StatefulWidget {
  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, 
        backgroundColor: Colors.white,
        elevation: 0, 
        title: Text(
          'Set up Your Activities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18, 
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            margin: const EdgeInsets.all(10),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF003B73),
              labelColor: Color(0xFF003B73),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.favorite), text: 'GRAT'),
                Tab(icon: Icon(Icons.handshake), text: 'AOK'),
                Tab(icon: Icon(Icons.book), text: 'JOUN'),
                Tab(icon: Icon(Icons.fitness_center), text: 'EXC'),
                Tab(icon: Icon(Icons.self_improvement), text: 'MED'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GratitudesScreen(),
                ActsOfKindnessScreen(),
                JournalScreen(),
                ExerciseTimerScreen(),
                MeditationTimerScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GratitudesScreen extends StatefulWidget {
  @override
  _GratitudesScreenState createState() => _GratitudesScreenState();
}

class _GratitudesScreenState extends State<GratitudesScreen> {
  late DatabaseReference _gratitudesRef;
  final List<Map<dynamic, dynamic>> _gratitudes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _gratitudesRef = FirebaseDatabase.instance.ref().child('gratitudes').child(user.uid);
      _gratitudesRef.onChildAdded.listen(_onGratitudeAdded);
      _gratitudesRef.onChildChanged.listen(_onGratitudeChanged);
      _gratitudesRef.onChildRemoved.listen(_onGratitudeRemoved);
    }
  }

  void _onGratitudeAdded(DatabaseEvent event) {
    setState(() {
      _gratitudes.add({'key': event.snapshot.key, 'value': event.snapshot.value});
    });
    _updateProgress();
  }

  void _onGratitudeChanged(DatabaseEvent event) {
    var old = _gratitudes.singleWhere((entry) => entry['key'] == event.snapshot.key);
    setState(() {
      _gratitudes[_gratitudes.indexOf(old)] = {'key': event.snapshot.key, 'value': event.snapshot.value};
    });
  }

  void _onGratitudeRemoved(DatabaseEvent event) {
    setState(() {
      _gratitudes.removeWhere((entry) => entry['key'] == event.snapshot.key);
    });
    _updateProgress();
  }

  void _addGratitude() {
    _gratitudesRef.push().set(_controller.text);
    _controller.clear();
    _updateProgress();
  }

  void _editGratitude(String key, String newGratitude) {
    _gratitudesRef.child(key).set(newGratitude);
  }

  void _removeGratitude(String key) {
    _gratitudesRef.child(key).remove();
  }

  void _updateProgress() {
    final progress = Provider.of<ProgressModel>(context, listen: false);
    progress.updateGratitudes(_gratitudes.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add a reason to be grateful',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addGratitude,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _gratitudes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_gratitudes[index]['value']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _controller.text = _gratitudes[index]['value'];
                          _editGratitude(_gratitudes[index]['key'], _controller.text);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeGratitude(_gratitudes[index]['key']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActsOfKindnessScreen extends StatefulWidget {
  @override
  _ActsOfKindnessScreenState createState() => _ActsOfKindnessScreenState();
}

class _ActsOfKindnessScreenState extends State<ActsOfKindnessScreen> {
  late DatabaseReference _actsRef;
  final List<Map<dynamic, dynamic>> _actsOfKindness = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _actsRef = FirebaseDatabase.instance.ref().child('actsOfKindness').child(user.uid);
      _actsRef.onChildAdded.listen(_onActAdded);
      _actsRef.onChildChanged.listen(_onActChanged);
      _actsRef.onChildRemoved.listen(_onActRemoved);
    }
  }

  void _onActAdded(DatabaseEvent event) {
    setState(() {
      _actsOfKindness.add({'key': event.snapshot.key, 'value': event.snapshot.value});
    });
    _updateProgress();
  }

  void _onActChanged(DatabaseEvent event) {
    var old = _actsOfKindness.singleWhere((entry) => entry['key'] == event.snapshot.key);
    setState(() {
      _actsOfKindness[_actsOfKindness.indexOf(old)] = {'key': event.snapshot.key, 'value': event.snapshot.value};
    });
  }

  void _onActRemoved(DatabaseEvent event) {
    setState(() {
      _actsOfKindness.removeWhere((entry) => entry['key'] == event.snapshot.key);
    });
    _updateProgress();
  }

  void _addActOfKindness() {
    _actsRef.push().set(_controller.text);
    _controller.clear();
    _updateProgress();
  }

  void _editActOfKindness(String key, String newAct) {
    _actsRef.child(key).set(newAct);
  }

  void _removeActOfKindness(String key) {
    _actsRef.child(key).remove();
  }

  void _updateProgress() {
    final progress = Provider.of<ProgressModel>(context, listen: false);
    progress.updateActsOfKindness(_actsOfKindness.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add an act of kindness',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addActOfKindness,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _actsOfKindness.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_actsOfKindness[index]['value']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _controller.text = _actsOfKindness[index]['value'];
                          _editActOfKindness(_actsOfKindness[index]['key'], _controller.text);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeActOfKindness(_actsOfKindness[index]['key']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late DatabaseReference _journalRef;
  final List<Map<dynamic, dynamic>> _journalEntries = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _journalRef = FirebaseDatabase.instance.ref().child('journalEntries').child(user.uid);
      _journalRef.onChildAdded.listen(_onJournalAdded);
      _journalRef.onChildChanged.listen(_onJournalChanged);
      _journalRef.onChildRemoved.listen(_onJournalRemoved);
    }
  }

  void _onJournalAdded(DatabaseEvent event) {
    setState(() {
      _journalEntries.add({'key': event.snapshot.key, 'value': event.snapshot.value});
    });
    _updateProgress();
  }

  void _onJournalChanged(DatabaseEvent event) {
    var old = _journalEntries.singleWhere((entry) => entry['key'] == event.snapshot.key);
    setState(() {
      _journalEntries[_journalEntries.indexOf(old)] = {'key': event.snapshot.key, 'value': event.snapshot.value};
    });
  }

  void _onJournalRemoved(DatabaseEvent event) {
    setState(() {
      _journalEntries.removeWhere((entry) => entry['key'] == event.snapshot.key);
    });
    _updateProgress();
  }

  void _addJournalEntry() {
    _journalRef.push().set(_controller.text);
    _controller.clear();
    _updateProgress();
  }

  void _editJournalEntry(String key, String newEntry) {
    _journalRef.child(key).set(newEntry);
  }

  void _removeJournalEntry(String key) {
    _journalRef.child(key).remove();
  }

  void _updateProgress() {
    final progress = Provider.of<ProgressModel>(context, listen: false);
    progress.updateJournalEntries(_journalEntries.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add a journal entry',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addJournalEntry,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _journalEntries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_journalEntries[index]['value']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _controller.text = _journalEntries[index]['value'];
                          _editJournalEntry(_journalEntries[index]['key'], _controller.text);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeJournalEntry(_journalEntries[index]['key']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseTimerScreen extends StatefulWidget {
  @override
  _ExerciseTimerScreenState createState() => _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen> {
  bool _isRunning = false;
  int _seconds = 0;
  late DatabaseReference _exerciseRef;
  late Timer _timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();
    _exerciseRef = FirebaseDatabase.instance.ref().child('exercise').child(FirebaseAuth.instance.currentUser!.uid);
  }

  void _startStopTimer() {
    if (_isRunning) {
      _timer.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
    _exerciseRef.set(_seconds);
    _updateProgress();
  }

  void _updateProgress() {
    final progress = Provider.of<ProgressModel>(context, listen: false);
    progress.updateExerciseMinutes(_seconds);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Time: ${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startStopTimer,
                child: Text(_isRunning ? 'Stop' : 'Start'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetTimer,
                child: Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MeditationTimerScreen extends StatefulWidget {
  @override
  _MeditationTimerScreenState createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen> {
  bool _isRunning = false;
  int _seconds = 0;
  late DatabaseReference _meditationRef;
  late Timer _timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();
    _meditationRef = FirebaseDatabase.instance.ref().child('meditation').child(FirebaseAuth.instance.currentUser!.uid);
  }

  void _startStopTimer() {
    if (_isRunning) {
      _timer.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
    _meditationRef.set(_seconds);
    _updateProgress();
  }

  void _updateProgress() {
    final progress = Provider.of<ProgressModel>(context, listen: false);
    progress.updateMeditationMinutes(_seconds);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Time: ${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startStopTimer,
                child: Text(_isRunning ? 'Stop' : 'Start'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetTimer,
                child: Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

