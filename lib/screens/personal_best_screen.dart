import 'package:flutter/material.dart';
import 'package:rep_max/services/firebase_service.dart';
import 'package:rep_max/models/workout.dart';
import 'package:intl/intl.dart';

class PersonalBestScreen extends StatefulWidget {
  const PersonalBestScreen({Key? key}) : super(key: key);

  @override
  State<PersonalBestScreen> createState() => _PersonalBestScreenState();
}

class _PersonalBestScreenState extends State<PersonalBestScreen> {
  final _firebaseService = FirebaseService();
  List<String> _exerciseNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _firebaseService.getExerciseNames();
      setState(() {
        _exerciseNames = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自己ベスト'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exerciseNames.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),
                      const Text('記録がありません'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _exerciseNames.length,
                  itemBuilder: (context, index) {
                    final exerciseName = _exerciseNames[index];
                    return FutureBuilder<Workout?>(
                      future: _firebaseService.getPersonalBest(exerciseName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final workout = snapshot.data;
                        if (workout == null) {
                          return const SizedBox.shrink();
                        }

                        final dateFormat = DateFormat('yyyy/MM/dd');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 4.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade100,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                        size: 24.0,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        workout.exerciseName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '${workout.weight}',
                                            style: const TextStyle(
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const Text('kg'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${workout.reps}',
                                            style: const TextStyle(
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const Text('回'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '${workout.sets}',
                                            style: const TextStyle(
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const Text('セット'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    '記録日: ${dateFormat.format(workout.timestamp)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
