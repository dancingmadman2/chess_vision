import 'package:chess_vision/components/database.dart';
import 'package:chess_vision/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CombinedPuzzles extends StatefulWidget {
  const CombinedPuzzles({super.key});

  @override
  State<CombinedPuzzles> createState() => _CombinedPuzzlesState();
}

class _CombinedPuzzlesState extends State<CombinedPuzzles> {
  Future<List<Puzzle>> getPuzzles() async {
    final String dbPath = await getDatabasePath();
    final db = await openDatabase(dbPath);
    final List<Map<String, dynamic>> maps = await db.query('puzzles');

    return List.generate(maps.length, (i) {
      return Puzzle(
        puzzleId: maps[i]['puzzleId'],
        fen: maps[i]['fen'],
        moves: maps[i]['moves'],
        rating: maps[i]['rating'],
        // ... other fields ...
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzles'),
      ),
      body: FutureBuilder<List<Puzzle>>(
        future: getPuzzles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Print the first puzzle's details to the console
            print('First puzzle: ${snapshot.data?.first.toMap()}');
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].puzzleId),
                  // ... other list tile properties ...
                );
              },
            );
          }
        },
      ),
    );
  }
}
