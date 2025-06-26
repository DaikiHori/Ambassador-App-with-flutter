// lib/models/user.dart

class User {
  final int? id; // ユーザーID (SQLiteのPRIMARY KEY AUTOINCREMENT)
  final String name; // ユーザー名

  User({
    this.id,
    required this.name,
  });

  // Userオブジェクトをデータベースに保存可能なMap形式に変換します。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // データベースから取得したMap形式のデータをUserオブジェクトに変換します。
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }
}
