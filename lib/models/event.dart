// lib/models/event.dart

class Event {
  final int? id; // イベントID (SQLiteのPRIMARY KEY AUTOINCREMENT)
  final String name; // イベント名
  final DateTime date; // イベント開催日時
  final String? url; // イベントURL (オプション)
  final int count; // 総参加可能人数または総チケット数
  final int usableCount; // 利用可能な残りの人数またはチケット数

  Event({
    this.id,
    required this.name,
    required this.date,
    this.url,
    required this.count,
    required this.usableCount,
  });

  // Eventオブジェクトをデータベースに保存可能なMap形式に変換します。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(), // DateTimeをISO 8601形式の文字列として保存
      'url': url,
      'count': count,
      'usable_count': usableCount,
    };
  }

  // データベースから取得したMap形式のデータをEventオブジェクトに変換します。
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String), // 保存された文字列からDateTimeにパース
      url: map['url'] as String?,
      count: map['count'] as int,
      usableCount: map['usable_count'] as int,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, name: $name, date: $date, url: $url, count: $count, usableCount: $usableCount}';
  }
}
