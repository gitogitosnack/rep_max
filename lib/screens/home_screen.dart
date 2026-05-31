import 'package:flutter/material.dart';
import 'package:rep_max/services/firebase_service.dart';
import 'package:rep_max/models/workout.dart';
import 'package:rep_max/screens/add_workout_screen.dart';
import 'package:rep_max/screens/personal_best_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RepMax'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Workout>>(
        stream: _firebaseService.getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('エラー: ${snapshot.error}'),
            );
          }

          final workouts = snapshot.data ?? [];

          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('筋トレ記録がありません'),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddWorkoutScreen(),
                        ),
                      );
                    },
                    child: const Text('記録を追加する'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(
                    workout.exerciseName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${workout.weight}kg × ${workout.reps}回 × ${workout.sets}セット\n${dateFormat.format(workout.timestamp)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDialog(workout.id!);
                    },
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'personal_best',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PersonalBestScreen(),
                ),
              );
            },
            tooltip: '自己ベストを見る',
            child: const Icon(Icons.emoji_events),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: 'add_workout',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddWorkoutScreen(),
                ),
              );
            },
            tooltip: '記録を追加',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String workoutId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: const Text('この記録を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                await _firebaseService.deleteWorkout(workoutId);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
