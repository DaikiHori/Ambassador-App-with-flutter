// lib/models/campfire_event.dart

// Campfire APIから取得するイベントの完全な詳細を表すモデル
class FullEvent {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // イベント画像URL (オプション)
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? startTime; // ISO 8601形式の文字列
  final String? endTime;   // ISO 8601形式の文字列
  final int? totalAttendees;
  final String? meetupUrl; // イベントの直接URL

  FullEvent({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.locationName,
    this.latitude,
    this.longitude,
    this.startTime,
    this.endTime,
    this.totalAttendees,
    this.meetupUrl,
  });

  factory FullEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['event'] as Map<String, dynamic>?;
    if (eventData == null) {
      throw FormatException("Invalid JSON: 'event' field is missing or null.");
    }

    return FullEvent(
      id: eventData['id'] as String,
      name: eventData['name'] as String,
      description: eventData['description'] as String,
      imageUrl: eventData['imageUrl'] as String?,
      locationName: eventData['location']?['name'] as String?,
      latitude: eventData['location']?['lat'] as double?,
      longitude: eventData['location']?['lon'] as double?,
      startTime: eventData['startTime'] as String?,
      endTime: eventData['endTime'] as String?,
      totalAttendees: eventData['totalAttendees'] as int?,
      meetupUrl: eventData['meetupUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'FullEvent(id: $id, name: $name, description: $description, meetupUrl: $meetupUrl)';
  }
}

// 公開イベントリストのレスポンスモデル
class Events {
  final List<PublicMapObject> publicMapObjectsByID;

  Events({required this.publicMapObjectsByID});

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      publicMapObjectsByID: (json['publicMapObjectsByID'] as List<dynamic>?)
          ?.map((e) => PublicMapObject.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// 地図上の公開オブジェクトを表すモデル
class PublicMapObject {
  final String id;
  final EventData event; // イベントデータ

  PublicMapObject({required this.id, required this.event});

  factory PublicMapObject.fromJson(Map<String, dynamic> json) {
    return PublicMapObject(
      id: json['id'] as String,
      event: EventData.fromJson(json['event'] as Map<String, dynamic>),
    );
  }
}

// イベントの基本データ（PublicMapObject内で使用）
class EventData {
  final String id;
  final String name;
  final String? meetupUrl;

  EventData({required this.id, required this.name, this.meetupUrl});

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      id: json['id'] as String,
      name: json['name'] as String,
      meetupUrl: json['meetupUrl'] as String?,
    );
  }
}
