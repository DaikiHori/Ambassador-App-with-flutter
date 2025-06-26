// lib/db_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'models/event.dart'; // Eventモデルをインポート
import 'models/user.dart';  // Userモデルをインポート
import 'models/code.dart';  // Codeモデルをインポート

class DbHelper {
  static final DbHelper _instance = DbHelper._internal(); // シングルトンインスタンス
  static Database? _database; // データベースインスタンス

  // プライベートコンストラクタ
  DbHelper._internal();

  // シングルトンインスタンスへのアクセサー
  static DbHelper get instance => _instance;

  // データベースを初期化し、取得するメソッド
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb(); // データベースがnullの場合のみ初期化
    return _database!;
  }

  // データベースを初期化する内部メソッド
  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory(); // アプリケーションのドキュメントディレクトリを取得
    final path = join(documentsDirectory.path, 'new_app_database.db'); // 新しいアプリのデータベースファイル名

    // データベースを開くか、存在しない場合は作成
    return await openDatabase(
      path,
      version: 1, // データベースのバージョン
      onCreate: _onCreate, // データベースが初めて作成されるときに呼ばれる
      onUpgrade: _onUpgrade, // データベースのバージョンが上がったときに呼ばれる
    );
  }

  // データベース作成時の処理 (テーブルのCREATE TABLE文を記述)
  Future<void> _onCreate(Database db, int version) async {
    // eventsテーブルの作成
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL, -- DateTimeはTEXTとして保存（ISO 8601形式）
        url TEXT,
        count INTEGER NOT NULL,
        usable_count INTEGER NOT NULL
      )
    ''');

    // usersテーブルの作成
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // codesテーブルの作成
    await db.execute('''
      CREATE TABLE codes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        event_id INTEGER NOT NULL, -- 外部キー
        code TEXT NOT NULL,
        usable INTEGER NOT NULL DEFAULT 1, -- デフォルト値1 (true)
        used INTEGER NOT NULL DEFAULT 0,   -- デフォルト値0 (false)
        user_name TEXT, -- 使用したユーザーの名前 (nullable)
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

  }

  // データベースアップグレード時の処理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // データベースのバージョンアップに伴うスキーマ変更ロジックをここに記述
    // 例:
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE events ADD COLUMN new_event_column TEXT;");
    // }
  }

  // MARK: - EventsテーブルのCRUD操作

  Future<int> insertEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<Event?> getEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MARK: - UsersテーブルのCRUD操作

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MARK: - CodesテーブルのCRUD操作

  Future<int> insertCode(Code code) async {
    final db = await database;
    return await db.insert('codes', code.toMap());
  }

  Future<List<Code>> getCodes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('codes');
    return List.generate(maps.length, (i) {
      return Code.fromMap(maps[i]);
    });
  }

  Future<Code?> getCodeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'codes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Code.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Code>> getCodesByEventId(int eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'codes',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return List.generate(maps.length, (i) {
      return Code.fromMap(maps[i]);
    });
  }

  Future<int> updateCode(Code code) async {
    final db = await database;
    return await db.update(
      'codes',
      code.toMap(),
      where: 'id = ?',
      whereArgs: [code.id],
    );
  }

  Future<int> deleteCode(int id) async {
    final db = await database;
    return await db.delete(
      'codes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllTables() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 外部キー制約があるため、依存関係の順に削除
      await txn.delete('codes');
      await txn.delete('events');
      await txn.delete('users');
    });
  }
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
