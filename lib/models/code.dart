// lib/models/code.dart

class Code {
  final int? id; // コードID (SQLiteのPRIMARY KEY AUTOINCREMENT)
  final int number; // コードの番号または連番
  final int eventId; // 関連するイベントのID (外部キー)
  final String code; // 実際のコード文字列
  final int usable; // 利用可能かどうか (0: false, 1: true)
  final int used; // 使用済みかどうか (0: false, 1: true)
  final String? userName; // 使用したユーザーの名前 (オプション)

  Code({
    this.id,
    required this.number,
    required this.eventId,
    required this.code,
    required this.usable,
    required this.used,
    this.userName,
  });

  // Codeオブジェクトをデータベースに保存可能なMap形式に変換します。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'event_id': eventId, // スネークケースで定義
      'code': code,
      'usable': usable,
      'used': used,
      'user_name': userName, // スネークケースで定義
    };
  }

  // データベースから取得したMap形式のデータをCodeオブジェクトに変換します。
  factory Code.fromMap(Map<String, dynamic> map) {
    return Code(
      id: map['id'] as int?,
      number: map['number'] as int,
      eventId: map['event_id'] as int, // スネークケースで取得
      code: map['code'] as String,
      usable: map['usable'] as int,
      used: map['used'] as int,
      userName: map['user_name'] as String?, // スネークケースで取得
    );
  }

  @override
  String toString() {
    return 'Code{id: $id, number: $number, eventId: $eventId, code: $code, usable: $usable, used: $used, userName: $userName}';
  }
}
