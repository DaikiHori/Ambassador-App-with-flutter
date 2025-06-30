// lib/screens/event_list_page.dart
import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../models/event.dart';
import '../models/code.dart';
import '../models/user.dart'; // Userモデルをインポート (エクスポート用)
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart';
import 'add_event_page.dart';
import 'code_list_page.dart';
import 'code_usage_page.dart';
import 'user_list_page.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert'; // UTF-8エンコーディングのために追加
import 'dart:typed_data'; // Uint8Listのために追加 (通常はdart:ioかdart:typed_dataのインポートで利用可能)
import 'package:csv/csv.dart'; // csvパッケージをインポート

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

  // CSVコンテンツを生成するヘルパー関数
  String _generateCsvContent(List<Event> events, List<User> users, List<Code> codes) {
    List<List<dynamic>> csvData = [];

    // Eventsテーブルのデータ
    csvData.add(['table', 'events']);
    csvData.add(['id', 'name', 'date', 'url', 'count', 'usable_count']);
    for (var event in events) {
      csvData.add([
        event.id,
        event.name,
        event.date.toIso8601String(), // DateTimeはISO 8601文字列で保存
        event.url ?? '', // nullの場合は空文字列
        event.count,
        event.usableCount,
      ]);
    }
    csvData.add([]); // 1行空ける

    // Usersテーブルのデータ
    csvData.add(['table', 'users']);
    csvData.add(['id', 'name']);
    for (var user in users) {
      csvData.add([
        user.id,
        user.name,
      ]);
    }
    csvData.add([]); // 1行空ける

    // Codesテーブルのデータ
    csvData.add(['table', 'codes']);
    csvData.add(['id', 'number', 'event_id', 'code', 'usable', 'used', 'user_name']);
    for (var code in codes) {
      csvData.add([
        code.id,
        code.number,
        code.eventId,
        code.code,
        code.usable,
        code.used,
        code.userName ?? '', // nullの場合は空文字列
      ]);
    }

    const converter = ListToCsvConverter(); // CSV変換器のインスタンス
    return converter.convert(csvData); // CSVデータを文字列に変換して返す
  }

  // エクスポート機能
  Future<void> _exportData() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // 全テーブルのデータを取得
      final events = await DbHelper.instance.getEvents();
      final users = await DbHelper.instance.getUsers();
      final codes = await DbHelper.instance.getCodes();

      // CSVコンテンツを生成
      String csvContent = _generateCsvContent(events, users, codes);

      // StringをUint8List（バイトデータ）に変換 (UTF-8エンコーディング)
      final List<int> bytes = utf8.encode(csvContent);
      final Uint8List data = Uint8List.fromList(bytes);

      // 保存先ファイルの選択ダイアログを表示し、バイトデータを渡す
      String? outputPath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: localizations.exportSelectLocationTitle,
        fileName: 'event_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        bytes: data!,
      );

      if (outputPath != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportSuccessMessage(outputPath))),
        );
      } else {
        // ユーザーがキャンセルした場合
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportCancelledMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.exportFailedMessage(e.toString()))),
      );
    }
  }

  // MARK: - インポート機能

  Future<void> _importData() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // CSVファイルを選択するダイアログを表示
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false, // 複数ファイル選択を許可しない
        dialogTitle: localizations.importSelectFileTitle,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;

        // 既存データ削除の確認アラート
        final bool? confirmImport = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.importConfirmTitle),
              content: Text(localizations.importConfirmMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // キャンセル
                  child: Text(localizations.cancelButtonText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // OK (削除してインポート)
                  child: Text(localizations.importConfirmButtonText),
                ),
              ],
            );
          },
        );

        if (confirmImport != true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.importCancelledMessage)),
          );
          return; // ユーザーがキャンセルした場合、ここで処理を中断
        }

        // ユーザーがOKを選択した場合、既存の全テーブルをクリア
        await DbHelper.instance.clearAllTables();
        final File file = File(filePath);
        String csvContent = await file.readAsString();
        csvContent = csvContent.replaceAll('\r\n', '\n');
        // CSVコンテンツを解析
        final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n').convert(csvContent);
        if (rows.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.importFailedMessage(localizations.csvImportFailedEmptyOrUnreadable))),
          );
          return; // パース結果が空の場合はここで処理を中断
        }
        String? currentTable;
        List<String>? currentHeaders;

        // CSVの旧IDからSQLiteの新規IDへのマッピング
        final Map<int, int> oldEventIdToNewEventId = {};
        final Map<int, int> oldUserIdToNewUserId = {}; // 将来的なユーザーデータインポートの拡張性

        int importedEvents = 0;
        int importedUsers = 0;
        int importedCodes = 0;
        int skippedRows = 0; // スキップされた行数をカウント

        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];

          // 空の行はテーブル区切りと判断
          if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
            currentTable = null; // テーブルコンテキストをリセット
            currentHeaders = null; // ヘッダーをリセット
            continue; // 次の行へ
          }

          // 最初の要素が 'table' であればテーブル名行
          if (row.length >= 2 && row[0] == 'table') {
            currentTable = row[1].toString();
            currentHeaders = null; // ヘッダーをリセット
            continue;
          } else if (currentTable != null && currentHeaders == null) {
            currentHeaders = row.map((e) => e.toString()).toList();
            currentHeaders = currentHeaders!.map((header) {
              // 正規表現を使ってキャメルケースをスネークケースに変換
              // 大文字の直前に_を挿入し、全てを小文字にする
              String snakeCaseHeader = header.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)?.toLowerCase()}');
              // 変換後、先頭に余分な'_'があれば削除 (例: "Id" -> "_id" -> "id")
              return snakeCaseHeader.startsWith('_') ? snakeCaseHeader.substring(1) : snakeCaseHeader;
            }).toList();
            continue;
          } else if (currentTable != null && currentHeaders != null) {
            // ヘッダーの次の行からデータ行
            final Map<String, dynamic> rowMap = {};
            for (int j = 0; j < currentHeaders.length; j++) {
              if (j < row.length) {
                // CSVパーサーが数字をint/doubleで返す場合があるので、toString()で一貫させる
                rowMap[currentHeaders[j]] = row[j];
              } else {
                rowMap[currentHeaders[j]] = null; // カラムが不足している場合はnull
              }
            }

            // 各テーブルのデータに応じて処理
            try {
              switch (currentTable) {
                case 'events':
                  final oldId = int.tryParse(rowMap['id'].toString());
                  final newEvent = Event(
                    // idはSQLiteに自動生成させるため、ここではnull
                    name: rowMap['name'].toString(),
                    date: DateTime.parse(rowMap['date'].toString()),
                    url: rowMap['url']?.toString().isEmpty == true ? null : rowMap['url'].toString(),
                    count: int.tryParse(rowMap['count'].toString()) ?? 0,
                    usableCount: int.tryParse(rowMap['usable_count'].toString()) ?? 0,
                  );
                  final newId = await DbHelper.instance.insertEvent(newEvent);
                  if (oldId != null) {
                    oldEventIdToNewEventId[oldId] = newId; // 旧IDと新IDのマッピングを保存
                  }
                  importedEvents++;
                  break;
                case 'users':
                // usersテーブルはUNIQUE制約があるため、insertUserのconflictAlgorithm.ignoreで重複はスキップされる
                  final oldId = int.tryParse(rowMap['id'].toString());
                  final newUser = User(
                    // idはSQLiteに自動生成させるため、ここではnull
                    name: rowMap['name'].toString(),
                  );
                  final newId = await DbHelper.instance.insertUser(newUser); // ignoreにより重複はスキップされる
                  if (newId != 0 && oldId != null) { // insertUserが0を返す場合、スキップされたことを意味する
                    oldUserIdToNewUserId[oldId] = newId; // 旧IDと新IDのマッピングを保存
                  } else if (newId == 0) {
                    skippedRows++; // スキップされたユーザーをカウント
                  }
                  importedUsers++; // insertUserが0を返しても、一応インポート試行数としてカウント
                  break;
                case 'codes':
                  final oldEventId = int.tryParse(rowMap['event_id'].toString());
                  // event_idがマッピングテーブルに存在するか確認
                  final newMappedEventId = (oldEventId != null && oldEventIdToNewEventId.containsKey(oldEventId))
                      ? oldEventIdToNewEventId[oldEventId]!
                      : null;

                  if (newMappedEventId == null) {
                    skippedRows++;
                    continue; // マッピングできない場合はこのコードをスキップ
                  }

                  // usable と used カラムのboolean文字列 ("true", "false") をint (1, 0) に変換する
                  final String? usableString = rowMap['usable']?.toString().toLowerCase().trim();
                  int parsedUsable = 1; // デフォルトは利用可能 (1)
                  if (usableString == 'true') {
                    parsedUsable = 1;
                  } else if (usableString == 'false') {
                    parsedUsable = 0;
                  } else {
                    // "true"/"false"でない場合は、intとしてパースを試みる (0または1)
                    parsedUsable = int.tryParse(usableString ?? '') ?? 1;
                  }

                  final String? usedString = rowMap['used']?.toString().toLowerCase().trim();
                  int parsedUsed = 0; // デフォルトは未利用 (0)
                  if (usedString == 'true') {
                    parsedUsed = 1;
                  } else if (usedString == 'false') {
                    parsedUsed = 0;
                  } else {
                    // "true"/"false"でない場合は、intとしてパースを試みる (0または1)
                    parsedUsed = int.tryParse(usedString ?? '') ?? 0;
                  }
                  final newCode = Code(
                    // idはSQLiteに自動生成させるため、ここではnull
                    number: int.tryParse(rowMap['number'].toString()) ?? 0,
                    eventId: newMappedEventId, // マッピングされた新しいeventIdを使用
                    code: rowMap['code'].toString(),
                    usable: parsedUsable,
                    used: parsedUsed,
                    userName: rowMap['user_name']?.toString().isEmpty == true ? null : rowMap['user_name'].toString(),
                  );
                  await DbHelper.instance.insertCode(newCode);
                  importedCodes++;
                  break;
                default:
                  skippedRows++;
              }
            } catch (e) {
              skippedRows++;
            }
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.importSummaryMessage(
                filePath,
                importedEvents,
                importedUsers,
                importedCodes,
                skippedRows,
              ),
            ),
            duration: const Duration(seconds: 5), // 長めに表示
          ),
        );
        await _loadEvents(); // インポート後、イベントリストを再ロードしてUIを更新
      } else {
        // ユーザーがキャンセルした場合、またはファイルが選択されなかった場合
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.importCancelledMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.importFailedMessage(e.toString()))),
      );
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
            const Divider(), // 区切り線

            // データエクスポート機能を追加
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(localizations.exportDataMenuText), // 新しい多言語キー
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                _exportData(); // エクスポート処理を呼び出す
              },
            ),
            // データインポート機能を追加
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(localizations.importDataMenuText), // 新しい多言語キー
              onTap: () {
                Navigator.pop(context); // ドロワーを閉じる
                _importData(); // インポート処理を呼び出す
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
