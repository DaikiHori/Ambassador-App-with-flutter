// lib/screens/event_list_page.dart

import 'package:flutter/material.dart';
import '../db_helper.dart'; // DbHelperをインポート
import '../models/event.dart'; // Eventモデルをインポート
// import 'add_event_page.dart'; // 後でイベント追加ページを作成したらインポートします

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> _events = []; // イベントのリスト
  bool _isLoading = true; // データロード中かどうかのフラグ

  @override
  void initState() {
    super.initState();
    _loadEvents(); // ページ初期化時にイベントをロード
  }

  // データベースからイベントのリストをロードするメソッド
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true; // ロード開始
    });
    try {
      final loadedEvents = await DbHelper.instance.getEvents(); // DbHelperからイベントを取得
      setState(() {
        _events = loadedEvents; // 取得したリストを更新
        _isLoading = false; // ロード完了
      });
      print('イベントがロードされました。件数: ${_events.length}'); // デバッグログ
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('イベントのロードに失敗しました: $e')),
      );
      setState(() {
        _isLoading = false; // ロード完了（エラー時も）
      });
      print('イベントのロードに失敗しました: $e'); // デバッグログ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント一覧'), // ヘッダーのタイトル
        actions: [
          // 右側からスライドインするドロワー（ハンバーガーメニュー）
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu), // ハンバーガーメニューアイコン
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // 右側ドロワーを開く
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer( // 右側ドロワーの定義
        // 後でメニューの中身をここに実装します
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue, // ドロワーヘッダーの背景色
              ),
              child: Text(
                'メニュー', // ドロワーヘッダーのテキスト
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // ここにメニュー項目を追加します（例：ListTileなど）
            // ListTile(
            //   leading: Icon(Icons.settings),
            //   title: Text('設定'),
            //   onTap: () {
            //     // 設定画面へ遷移
            //     Navigator.pop(context); // ドロワーを閉じる
            //   },
            // ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータ
          : _events.isEmpty
              ? const Center(
                  child: Text(
                    'イベントを作成してください', // イベントがない場合のメッセージ
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card( // イベントをカード形式で表示
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          event.name, // イベント名
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('日時: ${event.date.toLocal().toIso8601String().split('T')[0]}'), // 日時（日付のみ表示）
                            Text('総数: ${event.count}'), // 総参加可能人数
                            Text('利用可能数: ${event.usableCount}'), // 利用可能な残り人数
                            if (event.url != null && event.url!.isNotEmpty)
                              InkWell( // URLが設定されていればタップ可能に
                                onTap: () {
                                  // TODO: URLを開くロジックを実装
                                  print('URLを開く: ${event.url}');
                                },
                                child: Text(
                                  'URL: ${event.url}',
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey), // 編集ボタンのアイコン
                          onPressed: () {
                            // TODO: イベント編集ページへの遷移ロジックを実装
                            print('イベント編集: ${event.name}');
                          },
                        ),
                        onTap: () {
                          // TODO: イベント詳細ページなどへの遷移ロジックを実装
                          print('イベント詳細/編集タップ: ${event.name}');
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: イベント追加ページへの遷移ロジックを実装
          print('イベント追加ボタンが押されました');
          // 例: Navigator.push(context, MaterialPageRoute(builder: (context) => AddEventPage()));
        },
        tooltip: '新しいイベントを追加', // ツールチップ
        child: const Icon(Icons.add), // 追加アイコン
      ),
    );
  }
}
