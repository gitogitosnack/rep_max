import 'package:flutter/material.dart';
import 'package:rep_max/services/firebase_service.dart';
import 'package:rep_max/models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _firebaseService = FirebaseService();
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _setsController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  Future<void> _addWorkout() async {
    // バリデーション
    if (_exerciseController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _setsController.text.isEmpty) {
      setState(() {
        _errorMessage = '全てのフィールドを入力してください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workout = Workout(
        exerciseName: _exerciseController.text.trim(),
        weight: double.parse(_weightController.text),
        reps: int.parse(_repsController.text),
        sets: int.parse(_setsController.text),
        timestamp: DateTime.now(),
      );

      await _firebaseService.addWorkout(workout);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('筋トレ記録を追加'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // エラーメッセージ
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16.0),

            // 種目名フィールド
            StreamBuilder<List<String>>(
              stream: _firebaseService.getExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final exercises = snapshot.data ?? [];
                final selectedExercise = _exerciseController.text.isNotEmpty
                    ? _exerciseController.text
                    : null;

                return DropdownButtonFormField<String>(
                  value: exercises.contains(selectedExercise) ? selectedExercise : null,
                  decoration: InputDecoration(
                    labelText: '種目名を選択',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: exercises.map((exercise) {
                    return DropdownMenuItem<String>(
                      value: exercise,
                      child: Text(exercise),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _exerciseController.text = value;
                    }
                  },
                  isExpanded: true,
                );
              },
            ),
            const SizedBox(height: 16.0),

            // 重量フィールド
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: '重量 (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16.0),

            // 回数フィールド
            TextField(
              controller: _repsController,
              decoration: InputDecoration(
                labelText: '回数',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16.0),

            // セット数フィールド
            TextField(
              controller: _setsController,
              decoration: InputDecoration(
                labelText: 'セット数',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32.0),

            // 保存ボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _addWorkout,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '記録を保存',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
