import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/progress_model.dart';
import '../widgets/progress_wheel.dart';
import 'activities_screen.dart';
import 'news_screen.dart';
import 'settings_screen.dart';
import 'full_overview_screen.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    TodayProgressScreen(),
    ActivitiesScreen(),
    NewsScreen(),
    SettingsScreen(),
  ];

  static final List<String> _widgetTitles = <String>[
    "Today's Progress",
    "Activities",
    "News",
    "Settings"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressModel(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          title: Text(_widgetTitles[_selectedIndex]),
          backgroundColor: Color(0xFF003B73),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF003B73),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class TodayProgressScreen extends StatelessWidget {
  void _showFullOverview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FullOverviewScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressModel>(
      builder: (context, progress, child) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProgressWheel(percentage: progress.totalProgress),
                  SizedBox(height: 20),
                  _buildProgressItem('Gratitudes', progress.gratitudes, 3),
                  _buildProgressItem('Acts of Kindness', progress.actsOfKindness, 3),
                  _buildProgressItem('Journal Entries', progress.journalEntries, 1),
                  _buildProgressItem('Exercise', progress.exerciseMinutes, 20, 'min'),
                  _buildProgressItem('Meditation', progress.meditationMinutes, 30, 'min'),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey), 
                  _buildOverviewSection(context, progress),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String title, int current, int total, [String unit = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title: $current/$total $unit',
                style: TextStyle(fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: current >= total ? Color(0xFF003B73) : Colors.grey,
                ),
                width: 20,
                height: 20,
                child: current >= total
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 5),
          LinearProgressIndicator(
            value: total == 0 ? 0 : current / total, 
            backgroundColor: Colors.grey[300],
            color: Color(0xFF003B73),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, ProgressModel progress) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEAA318),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _showFullOverview(context), 
                  child: Text('View All'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildOverviewItem('Gratitudes', progress.gratitudes),
          _buildOverviewItem('Acts of Kindness', progress.actsOfKindness),
          _buildOverviewItem('Journal Entries', progress.journalEntries),
          _buildOverviewItem('Exercise', progress.exerciseMinutes, 'min'),
          _buildOverviewItem('Meditation', progress.meditationMinutes, 'min'),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, int count, [String unit = '']) {
    String message = '';
    if (count >= 3) {
      message = 'Congratulations!';
    } else if (count >= 2) {
      message = 'You\'re halfway there!';
    } else if (count >= 1) {
      message = 'Nicely done, keep it up!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '$title $unit',
            style: TextStyle(fontSize: 18),
          ),
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                message,
                style: TextStyle(color: Color(0xFF003B73), fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
