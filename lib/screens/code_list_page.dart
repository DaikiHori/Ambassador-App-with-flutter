// lib/screens/code_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // クリップボード操作用
import '../db_helper.dart';             // DbHelperをインポート
import '../models/code.dart';            // Codeモデルをインポート
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用

class CodeListPage extends StatefulWidget {
  final int eventId; // このページで表示するコードが紐づくイベントID
  final String eventName; // AppBarに表示するイベント名

  const CodeListPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<CodeListPage> createState() => _CodeListPageState();
}

class _CodeListPageState extends State<CodeListPage> {
  List<Code> _codes = []; // このイベントに紐づくコードのリスト
  bool _isLoading = true; // データロード中かどうかのフラグ
  // 各コードのユーザー名入力用コントローラーを管理するマップ
  final Map<int, TextEditingController> _userNameControllers = {};

  @override
  void initState() {
    super.initState();
    _loadCodes(); // ページ初期化時にコードをロード
  }

  @override
  void dispose() {
    // ページが破棄されるときにすべてのコントローラーを破棄
    _userNameControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // データベースからコードのリストをロードするメソッド
  Future<void> _loadCodes() async {
    setState(() {
      _isLoading = true; // ロード開始
    });
    try {
      final loadedCodes = await DbHelper.instance.getCodesByEventId(widget.eventId); // 特定のイベントIDでコードを取得

      // コントローラーを初期化または更新
      for (var code in loadedCodes) {
        if (code.id != null) {
          _userNameControllers.putIfAbsent(code.id!, () => TextEditingController(text: code.userName));
          // 既に存在する場合はテキストを更新
          _userNameControllers[code.id!]!.text = code.userName ?? '';
        }
      }

      setState(() {
        _codes = loadedCodes; // 取得したリストを更新
        _isLoading = false; // ロード完了
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loadCodeError(e.toString()))),
      );
      setState(() {
        _isLoading = false; // ロード完了（エラー時も）
      });
    }
  }

  // コードの情報を更新するメソッド
  Future<void> _updateCode(Code code) async {
    try {
      // 現在のUIの状態（チェックボックス、テキストフィールド）に基づいてCodeオブジェクトを更新
      final updatedCode = code.copyWith(
        usable: code.usable, // チェックボックスから直接StatefulBuilder内で更新される
        used: code.used,     // チェックボックスから直接StatefulBuilder内で更新される
        userName: _userNameControllers[code.id!]?.text.isEmpty == true
            ? null
            : _userNameControllers[code.id!]?.text,
      );

      await DbHelper.instance.updateCode(updatedCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.codeSavedSuccess(code.code))),
      );
      // _loadCodes(); // 更新後のリストを再ロード (必要であれば)
      // シンプルな更新であれば、UIの状態を直接更新するだけでも良い
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.codeSaveFailed(e.toString()))),
      );
    }
  }

  // コードをクリップボードにコピーするメソッド
  Future<void> _copyCodeToClipboard(String codeText) async {
    await Clipboard.setData(ClipboardData(text: codeText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copiedCodeMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.codeListPageTitle(widget.eventName)), // イベント名を含むタイトル
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータ
          : _codes.isEmpty
          ? Center(
        child: Text(
          localizations.noCodesMessage, // コードがない場合のメッセージ
          style: const TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _codes.length,
        itemBuilder: (context, index) {
          var code = _codes[index];
          // StatefulBuilderを使用して、ListItem個別の状態（チェックボックス）を管理
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setInnerState) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // number:code (コピー可能)
                      GestureDetector(
                        onTap: () => _copyCodeToClipboard(code.code),
                        child: Text(
                          '${code.number} : ${code.code}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // コピー可能であることを示す色
                            decoration: TextDecoration.underline, // 下線
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // usableチェックボックス
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: code.usable == 1,
                                onChanged: (bool? newValue) {
                                  if (newValue != null) {
                                    setInnerState(() {
                                      code = code.copyWith(usable: newValue ? 1 : 0);
                                    });
                                  }
                                },
                              ),
                              Text(localizations.codeUsableLabel),
                            ],
                          ),

                          // usedチェックボックス
                          Row(
                            children: [
                              Checkbox(
                                value: code.used == 1,
                                onChanged: (bool? newValue) {
                                  if (newValue != null) {
                                    setInnerState(() {
                                      code = code.copyWith(used: newValue ? 1 : 0);
                                    });
                                  }
                                },
                              ),
                              Text(localizations.codeUsedLabel),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Expanded( // TextFormFieldがスペースを埋めるようにする
                            child: TextFormField(
                              controller: _userNameControllers[code.id!],
                              decoration: InputDecoration(
                                labelText: localizations.codeUserNameLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onChanged: (value) {
                                // コントローラーのテキストは自動で更新されるため、ここで特別な処理は不要
                              },
                            ),
                          ),
                          const SizedBox(width: 8.0), // テキストフィールドとボタンの間のスペース
                          ElevatedButton( // 保存ボタン
                            onPressed: () => _updateCode(code), // 更新対象のコードを渡す
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(localizations.saveButtonText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
