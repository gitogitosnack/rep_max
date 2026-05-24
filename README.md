# Rep Max - 筋トレ記録アプリ

Flutter × Firebase を使用した、シンプルで使いやすい筋トレ記録アプリです。

## 機能

### ✅ 実装済み機能

- **ユーザー認証**
  - Firebase Authentication を使用したメールアドレス・パスワード認証
  - ユーザー登録・ログイン・ログアウト機能

- **筋トレ記録の管理**
  - 日付、種目名、重量（kg）、回数、セット数を記録
  - 記録一覧を時系列（新しい順）で表示
  - 記録の削除機能

- **自己ベスト表示**
  - 種目ごとの最大重量を自動抽出
  - 種目別に自己ベストを美しく表示

- **オフライン対応（Firestore標準機能）**
  - ローカルキャッシュにより、オフライン状態でもデータにアクセス可能
  - 電波が入った時に自動で同期

## アーキテクチャ

### データ構造（Firestore）

```
users (コレクション)
  └ [ユーザーID] (ドキュメント)
      ├ name: "ユーザー名"
      ├ email: "example@example.com"
      ├ createdAt: タイムスタンプ
      └ workouts (サブコレクション)
          └ [自動生成されたID] (ドキュメント)
              ├ timestamp: 日付・時間
              ├ exerciseName: "ベンチプレス"
              ├ weight: 80.0
              ├ reps: 10
              └ sets: 3
```

### ファイル構成

```
lib/
├── main.dart                    # アプリケーション起動点、Firebase初期化
├── firebase_options.dart        # Firebase設定
├── models/
│   └── workout.dart            # 筋トレ記録データモデル
├── services/
│   └── firebase_service.dart   # Firebase操作を一元管理するサービス
└── screens/
    ├── auth_screen.dart        # ユーザー認証画面
    ├── home_screen.dart        # ホーム画面（記録一覧表示）
    ├── add_workout_screen.dart # 記録追加画面
    └── personal_best_screen.dart # 自己ベスト表示画面
```

## セットアップ方法

### 前提条件
- Flutter SDK がインストール済みであること
- Firebase プロジェクトが作成済みであること

### 1. Firebaseプロジェクトの設定

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 新規プロジェクトを作成（または既存プロジェクトを選択）
3. Authentication を有効化（メール/パスワード認証）
4. Firestore Database を有効化

### 2. アプリケーション設定

1. FlutterFire CLI をインストール
```bash
dart pub global activate flutterfire_cli
```

2. Firebase プロジェクトを接続
```bash
flutterfire configure
```

3. `firebase_options.dart` が自動生成されます（手動設定の場合は、自分のFirebaseプロジェクトの認証情報を入力）

### 3. 依存パッケージをインストール
```bash
flutter pub get
```

### 4. アプリを実行
```bash
flutter run
```

## 使用技術

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication（認証）
  - Cloud Firestore（リアルタイムデータベース）
  - Cloud Functions（将来の拡張用）

## 利点

✨ **爆速開発**: インフラ構築が不要で、UIに集中できる
📱 **オフライン対応**: Firestoreのローカルキャッシュで電波がなくても使用可能
🔐 **セキュアな認証**: Firebase Authenticationで安全なユーザー管理
💰 **低コスト**: ユーザー数が増えるまでは無料枠内で運用可能
📚 **豊富なドキュメント**: Flutter × Firebase の情報・ライブラリが充実

## 今後の拡張予定

- [ ] 複数種目の統計・グラフ表示
- [ ] トレーニング目標の設定機能
- [ ] SNS連携（成果の共有）
- [ ] プッシュ通知（トレーニング日の通知）
- [ ] 多言語対応

## ライセンス

MIT License

## お問い合わせ

何かご質問やご提案があれば、Issueを作成してください。
