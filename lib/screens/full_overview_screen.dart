import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/progress_model.dart';

class FullOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Overview'),
        backgroundColor: Color(0xFF003B73),
      ),
      body: Consumer<ProgressModel>(
        builder: (context, progress, child) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEntrySection(context, 'Gratitudes', progress.gratitudeEntries),
                    _buildEntrySection(context, 'Acts of Kindness', progress.kindnessEntries),
                    _buildEntrySection(context, 'Journal Entries', progress.journalEntriesList),
                    _buildEntrySection(context, 'Exercise', progress.exerciseEntries, 'min'),
                    _buildEntrySection(context, 'Meditation', progress.meditationEntries, 'min'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntrySection(BuildContext context, String title, List<String> entries, [String unit = '']) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Set a white background for better contrast
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Add shadow for a better visual effect
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF003B73)),
          ),
          SizedBox(height: 10),
          if (entries.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: entries.map((entry) => _buildEntryItem(entry, unit)).toList(),
            )
          else
            Text(
              'No entries yet.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF003B73),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              context.read<ProgressModel>().fetchDataFromDatabase();
            },
            child: Text('Load New Updates'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(String entry, String unit) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF003B73).withOpacity(0.1), // Add a light color background for each entry
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        entry + (unit.isNotEmpty ? ' $unit' : ''),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
