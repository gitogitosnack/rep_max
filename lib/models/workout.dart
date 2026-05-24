import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String? id;
  final String exerciseName;
  final double weight;
  final int reps;
  final int sets;
  final DateTime timestamp;

  Workout({
    this.id,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.timestamp,
  });

  // Firestoreドキュメントから Workoutオブジェクトを生成
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      exerciseName: data['exerciseName'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      reps: data['reps'] ?? 0,
      sets: data['sets'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // WorkoutオブジェクトをFirestoreフォーマットに変換
  Map<String, dynamic> toFirestore() {
    return {
      'exerciseName': exerciseName,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
