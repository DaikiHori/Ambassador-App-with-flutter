// lib/screens/event_list_page.dart

import 'package:ambassador_app_with_flutter/screens/code_list_page.dart';
import 'package:ambassador_app_with_flutter/screens/code_usage_page.dart';
import 'package:ambassador_app_with_flutter/screens/user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart'; // DbHelperをインポート
import '../l10n/app_localizations.dart';
import '../models/event.dart'; // Eventモデルをインポート
import '../models/code.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

// UI表示のためにEventと算出されたコード数を組み合わせたデータモデル
class EventDisplayData {
  final Event event; // 元のイベントデータ
  final int totalCodes; // このイベントの総コード数
  final int usableCodes; // このイベントの利用可能なコード数

  EventDisplayData({
    required this.event,
    required this.totalCodes,
    required this.usableCodes,
  });
}

class _EventListPageState extends State<EventListPage> {
  List<EventDisplayData> _eventDisplayDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents(); // ページ初期化時にイベントをロード
  }

  // データベースからイベントのリストと関連するコードをロードし、表示データを準備するメソッド
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final loadedEvents = await DbHelper.instance.getEvents(); // すべてのイベントを取得
      List<EventDisplayData> tempDisplayDataList = [];

      for (final event in loadedEvents) {
        // 各イベントに関連するコードを取得
        final List<Code> relatedCodes = await DbHelper.instance
            .getCodesByEventId(event.id!);

        final int totalCodes = relatedCodes.length; // 総コード数
        // usableが1 かつ usedが0 のコードをカウント
        final int usableCodes = relatedCodes
            .where((code) => code.usable == 1 && code.used == 0)
            .length;

        tempDisplayDataList.add(
          EventDisplayData(
            event: event,
            totalCodes: totalCodes,
            usableCodes: usableCodes,
          ),
        );
      }

      setState(() {
        _eventDisplayDataList = tempDisplayDataList; // 表示用リストを更新
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loadEventFailed(e.toString()))));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.eventListPageTitle), // ヘッダーのタイトル
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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                localizations.menuTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // UserListPageへのナビゲーションリンクを追加
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(localizations.userListMenuText),
              onTap: () async {
                Navigator.pop(context); // ドロワーを閉じる
                // UserListPageへの遷移
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserListPage()),
                );
              },
            ),
            // その他のメニュー項目をここに追加
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータ
          : _eventDisplayDataList.isEmpty
          ? Center(
              child: Text(
                localizations.createEventMessage,// イベントがない場合のメッセージ
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _eventDisplayDataList.length,
        itemBuilder: (context, index) {
          final displayData = _eventDisplayDataList[index];
          final event = displayData.event;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Column( // ListTileとボタンを縦に並べるためにColumnで囲む
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${displayData.usableCodes}/${displayData.totalCodes}',
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${localizations.eventDateLabel}: ${DateFormat('yyyy/MM/dd').format(event.date.toLocal())}'),
                    ],
                  ),
                ),
                // カード下部にボタンを配置するエリア
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, // ボタンを均等配置
                    children: [
                      Expanded(
                        child: OutlinedButton.icon( // 編集ボタン
                          icon: const Icon(Icons.edit),
                          label: Text(localizations.editButtonText),
                          onPressed: () async {
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEventPage(eventToEdit: event), // 編集対象を渡す
                              ),
                            );
                            if (result == true) {
                              _loadEvents(); // 編集・削除が行われたらリストを再ロード
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: OutlinedButton.icon( // コード一覧ボタン
                          icon: const Icon(Icons.list),
                          label: Text(localizations.codeListButtonText),
                          onPressed: () async {
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CodeListPage(eventId: event.id! ,eventName: event.name), // 編集対象を渡す
                              ),
                            );
                            if (result == true) {
                              _loadEvents(); // 編集・削除が行われたらリストを再ロード
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: OutlinedButton.icon( // コードボタン
                          icon: const Icon(Icons.qr_code),
                          label: Text(localizations.codeButtonText),
                          onPressed: () async {
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CodeUsagePage(eventId: event.id!, eventName: event.name),
                              ),
                            );
                            if (result == true) {
                              _loadEvents(); // 編集・削除が行われたらリストを再ロード
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 新しいイベント追加ページに遷移
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventPage()),
          );
          // 新しいイベントが追加された場合はリストを再ロード
          if (result == true) {
            _loadEvents();
          }
        },
        tooltip: localizations.addNewEventTooltip, // ツールチップ
        child: const Icon(Icons.add), // 追加アイコン
      ),
    );
  }
}
