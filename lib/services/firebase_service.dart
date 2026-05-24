import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rep_max/models/workout.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // メールアドレスとパスワードでユーザー登録
  Future<UserCredential> signUp(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ユーザープロフィールを設定
      await credential.user!.updateDisplayName(displayName);

      // Firestoreにユーザー情報を保存
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': displayName,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // メールアドレスとパスワードでログイン
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 筋トレ記録を保存
  Future<void> addWorkout(Workout workout) async {
    if (currentUser == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('workouts')
        .add(workout.toFirestore());
  }

  // 全ての筋トレ記録を取得（時系列の降順）
  Stream<List<Workout>> getWorkouts() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
    });
  }

  // 特定の種目の自己ベストを取得
  Future<Workout?> getPersonalBest(String exerciseName) async {
    if (currentUser == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('workouts')
        .where('exerciseName', isEqualTo: exerciseName)
        .orderBy('weight', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Workout.fromFirestore(snapshot.docs.first);
  }

  // 全種目の一覧を取得
  Future<List<String>> getExerciseNames() async {
    if (currentUser == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('workouts')
        .get();

    final exerciseNames = <String>{};
    for (var doc in snapshot.docs) {
      exerciseNames.add(doc['exerciseName'] as String);
    }

    return exerciseNames.toList()..sort();
  }

  // 筋トレ記録を削除
  Future<void> deleteWorkout(String workoutId) async {
    if (currentUser == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }
}
