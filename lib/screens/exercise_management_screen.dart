import 'package:flutter/material.dart';
import 'package:rep_max/services/firebase_service.dart';

class ExerciseManagementScreen extends StatefulWidget {
  const ExerciseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseManagementScreen> createState() => _ExerciseManagementScreenState();
}

class _ExerciseManagementScreenState extends State<ExerciseManagementScreen> {
  final _firebaseService = FirebaseService();
  final _exerciseController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exerciseName = _exerciseController.text.trim();

    if (exerciseName.isEmpty) {
      setState(() {
        _errorMessage = '種目名を入力してください';
      });
      return;
    }

    try {
      await _firebaseService.addExercise(exerciseName);
      _exerciseController.clear();
      setState(() {
        _errorMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「$exerciseName」を登録しました')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラー: $e';
      });
    }
  }

  Future<void> _deleteExercise(String exerciseName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: Text('「$exerciseName」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firebaseService.deleteExercise(exerciseName);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('「$exerciseName」を削除しました')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('削除に失敗しました: $e')),
                    );
                  }
                }
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('種目管理'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 種目追加フォーム
          Padding(
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

                // 種目名入力フィールド
                TextField(
                  controller: _exerciseController,
                  decoration: InputDecoration(
                    labelText: '種目名を入力',
                    hintText: '例：ベンチプレス、スクワット',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // 追加ボタン
                ElevatedButton(
                  onPressed: _addExercise,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('種目を追加', style: TextStyle(fontSize: 16.0)),
                  ),
                ),
              ],
            ),
          ),

          // 種目一覧
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _firebaseService.getExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('エラー: ${snapshot.error}'),
                  );
                }

                final exercises = snapshot.data ?? [];

                if (exercises.isEmpty) {
                  return const Center(
                    child: Text('登録された種目はありません'),
                  );
                }

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];

                    return ListTile(
                      title: Text(exercise),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteExercise(exercise);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
