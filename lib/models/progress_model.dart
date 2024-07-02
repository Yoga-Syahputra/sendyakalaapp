import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressModel extends ChangeNotifier {
  int _gratitudes = 0;
  int _actsOfKindness = 0;
  int _journalEntries = 0;
  int _exerciseMinutes = 0;
  int _meditationMinutes = 0;

  List<String> _gratitudeEntries = [];
  List<String> _kindnessEntries = [];
  List<String> _journalEntriesList = [];
  List<String> _exerciseEntries = [];
  List<String> _meditationEntries = [];

  int get gratitudes => _gratitudes;
  int get actsOfKindness => _actsOfKindness;
  int get journalEntries => _journalEntries;
  int get exerciseMinutes => _exerciseMinutes;
  int get meditationMinutes => _meditationMinutes;

  List<String> get gratitudeEntries => _gratitudeEntries;
  List<String> get kindnessEntries => _kindnessEntries;
  List<String> get journalEntriesList => _journalEntriesList;
  List<String> get exerciseEntries => _exerciseEntries;
  List<String> get meditationEntries => _meditationEntries;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> fetchDataFromDatabase() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      try {
        _databaseReference.child('gratitudes/$uid').onValue.listen((event) {
          _gratitudeEntries = _parseEntries(event.snapshot.value);
          notifyListeners();
        });

        _databaseReference.child('actsOfKindness/$uid').onValue.listen((event) {
          _kindnessEntries = _parseEntries(event.snapshot.value);
          notifyListeners();
        });

        _databaseReference.child('journalEntries/$uid').onValue.listen((event) {
          _journalEntriesList = _parseEntries(event.snapshot.value);
          notifyListeners();
        });

        _databaseReference.child('exercise/$uid').onValue.listen((event) {
          _exerciseEntries = _parseEntries(event.snapshot.value);
          notifyListeners();
        });

        _databaseReference.child('meditation/$uid').onValue.listen((event) {
          _meditationEntries = _parseEntries(event.snapshot.value);
          notifyListeners();
        });
      } catch (error) {
        throw Exception('Failed to load data: $error');
      }
    }
  }

  List<String> _parseEntries(dynamic data) {
    List<String> entries = [];
    if (data != null) {
      data.forEach((key, value) {
        entries.add(value.toString());
      });
    }
    return entries;
  }

  void updateGratitudes(int count) {
    _gratitudes = count;
    notifyListeners();
  }

  void addGratitudeEntry(String entry) {
    _gratitudeEntries.add(entry);
    notifyListeners();
  }

  void updateActsOfKindness(int count) {
    _actsOfKindness = count;
    notifyListeners();
  }

  void addKindnessEntry(String entry) {
    _kindnessEntries.add(entry);
    notifyListeners();
  }

  void updateJournalEntries(int count) {
    _journalEntries = count;
    notifyListeners();
  }

  void addJournalEntry(String entry) {
    _journalEntriesList.add(entry);
    notifyListeners();
  }

  void updateExerciseMinutes(int minutes) {
    _exerciseMinutes = minutes;
    notifyListeners();
  }

  void addExerciseEntry(String entry) {
    _exerciseEntries.add(entry);
    notifyListeners();
  }

  void updateMeditationMinutes(int minutes) {
    _meditationMinutes = minutes;
    notifyListeners();
  }

  void addMeditationEntry(String entry) {
    _meditationEntries.add(entry);
    notifyListeners();
  }

  void resetAllData() {
    _gratitudes = 0;
    _actsOfKindness = 0;
    _journalEntries = 0;
    _exerciseMinutes = 0;
    _meditationMinutes = 0;

    _gratitudeEntries.clear();
    _kindnessEntries.clear();
    _journalEntriesList.clear();
    _exerciseEntries.clear();
    _meditationEntries.clear();

    notifyListeners();
  }

  double get totalProgress {
    int totalTasks = 5; // number of tracked activities
    double progress = 0.0;

    if (_gratitudes >= 3) progress += 1.0 / totalTasks;
    if (_actsOfKindness >= 3) progress += 1.0 / totalTasks;
    if (_journalEntries >= 1) progress += 1.0 / totalTasks;
    if (_exerciseMinutes >= 20) progress += 1.0 / totalTasks;
    if (_meditationMinutes >= 30) progress += 1.0 / totalTasks;

    return progress;
  }
}
