// lib/screens/code_usage_page.dart

import 'package:flutter/material.dart';
import '../db_helper.dart';             // DbHelperをインポート
import '../models/code.dart';            // Codeモデルをインポート
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用
import 'package:qr_flutter/qr_flutter.dart'; // QRコード生成ライブラリ

class CodeUsagePage extends StatefulWidget {
  final int eventId; // このページで利用するコードが紐づくイベントID
  final String eventName; // AppBarに表示するイベント名

  const CodeUsagePage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<CodeUsagePage> createState() => _CodeUsagePageState();
}

class _CodeUsagePageState extends State<CodeUsagePage> {
  Code? _targetCode; // 表示する対象のコード
  bool _isLoading = true; // データロード中かどうかのフラグ
  String _qrDataUrl = ''; // QRコードとして表示するURLデータ

  // UIで一時的に変更されるusable/usedの状態を保持（保存ボタン押下までDBに反映しない）
  bool _currentUsableState = true; // _targetCodeがusableの時の状態
  bool _currentUsedState = false;  // _targetCodeがusedの時の状態
  // ユーザー名入力用コントローラー
  final TextEditingController _userNameController = TextEditingController();
  // ここに、コードをリダイレクトするベースURLを設定します。
  static const String _baseUrl = 'https://store.pokemongolive.com/offer-redemption?passcode=';

  @override
  void initState() {
    super.initState();
    _loadAndPrepareCode(); // ページ初期化時にコードをロードして準備
  }

  // 利用可能かつ未使用の最初のコードをロードし、QRコードデータを準備するメソッド
  Future<void> _loadAndPrepareCode() async {
    setState(() {
      _isLoading = true; // ロード開始
    });
    try {
      final allCodes = await DbHelper.instance.getCodesByEventId(widget.eventId); // イベントIDで全てのコードを取得

      // usable=1 かつ used=0 のコードの中から最初の1つを見つける
      final usableUnusedCodes = allCodes.where((code) => code.usable == 1 && code.used == 0).toList();

      if (usableUnusedCodes.isNotEmpty) {
        _targetCode = usableUnusedCodes.first; // 最初のコードを取得
        _qrDataUrl = '$_baseUrl${_targetCode!.code}'; // QRコードのデータとなるURLを生成
        // ロードしたコードの初期状態をUIのスイッチに反映
        _currentUsableState = _targetCode!.usable == 1;
        _currentUsedState = _targetCode!.used == 1;
        _userNameController.text = _targetCode!.userName ?? '';
      } else {
        _targetCode = null; // コードが見つからなかった場合
        _qrDataUrl = ''; // QRデータもクリア
      }

      setState(() {
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

  // コードの状態を保存するメソッド (usable/usedを更新)
  Future<void> _saveCodeState() async {
    if (_targetCode == null || _targetCode!.id == null) {
      return;
    }
    try {
      // UIの現在のスイッチの状態に基づいてCodeオブジェクトを更新
      final updatedCode = _targetCode!.copyWith(
        usable: _currentUsableState ? 1 : 0,
        used: _currentUsedState ? 1 : 0,
        userName: _userNameController.text.isEmpty ? null : _userNameController.text,
      );

      await DbHelper.instance.updateCode(updatedCode);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.codeSavedSuccess(_targetCode!.code))),
      );

      // 保存後、最新のデータで画面をリロード (次の利用可能なコードを自動でロード)
      _loadAndPrepareCode();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.codeSaveFailed(e.toString()))),
      );
    }
  }

  // ユーザー名の候補をフィルタリングして返す非同期メソッド
  Future<Iterable<String>> _fetchUserSuggestions(String query) async {
    if (query.isEmpty) {
      return const Iterable<String>.empty();
    }
    final allUsers = await DbHelper.instance.getUsers();
    return allUsers
        .where((user) => user.name.toLowerCase().startsWith(query.toLowerCase()))
        .map((user) => user.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.codeUsagePageTitle(widget.eventName)), // イベント名を含むタイトル
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータ
          : _targetCode == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            localizations.noUsableCodesAvailable, // 利用可能なコードがない場合のメッセージ
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : Center(
        child: SingleChildScrollView( // QRコードが大きい場合のためにスクロール可能にする
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // コード番号とコード文字列 (QRコードの上に配置)
              Row(
                children: [
                  Text(
                    '${_targetCode!.number} : ',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                  SelectableText( // コード文字列はコピー可能に
                    _targetCode!.code,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // QRコードの表示 (より大きく中央に)
              QrImageView(
                data: _qrDataUrl, // 生成したURLをQRコードデータとして渡す
                version: QrVersions.auto, // 自動でバージョンを決定
                size: MediaQuery.of(context).size.width * 0.7, // 画面幅の70%を使用
                gapless: true, // QRコードの余白をなくす
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(60, 60),
                ),
                // エラー時のメッセージ
                errorStateBuilder: (cxt, err) {
                  return Center(
                    child: Text(
                      localizations.qrCodeGenerationError(err.toString()),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // usableスイッチ
              SwitchListTile(
                title: Text(localizations.codeUsableLabel),
                value: _currentUsableState,
                onChanged: (bool newValue) {
                  setState(() {
                    _currentUsableState = newValue;
                  });
                },
              ),
              // usedスイッチ
              SwitchListTile(
                title: Text(localizations.codeUsedLabel),
                value: _currentUsedState,
                onChanged: (bool newValue) {
                  setState(() {
                    _currentUsedState = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),
              // ユーザー名入力テキストボックス (オートコンプリート付き)
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _fetchUserSuggestions(textEditingValue.text);
                },
                onSelected: (String selection) {
                  _userNameController.text = selection; // 選択された候補をテキストフィールドにセット
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  // Autocompleteの内部コントローラーを外部の_userNameControllerに同期
                  // 初期ロード時や候補選択時に_userNameControllerが更新されるようにする
                  if (textEditingController.text != _userNameController.text) {
                    textEditingController.text = _userNameController.text;
                    // カーソル位置をテキストの最後に移動させる (オプション)
                    textEditingController.selection = TextSelection.fromPosition(
                      TextPosition(offset: textEditingController.text.length),
                    );
                  }
                  return TextFormField(
                    controller: textEditingController, // Autocompleteが提供するコントローラーを使用
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: localizations.codeUserNameLabel, // 多言語対応
                      hintText: localizations.codeUserNameHint, // 多言語対応
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) { // ユーザーが手動で入力したときに_userNameControllerを更新
                      _userNameController.text = value;
                    },
                    onFieldSubmitted: (String value) {
                      onFieldSubmitted(); // オートコンプリートの submit イベントをトリガー
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: MediaQuery.of(context).size.width * 0.8), // 候補リストの最大幅と高さ
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // 保存ボタン
              ElevatedButton.icon(
                onPressed: _saveCodeState, // スイッチの状態を保存
                icon: const Icon(Icons.save),
                label: Text(localizations.saveButtonText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor, // プライマリカラーを使用
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
