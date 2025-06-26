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

  // ここに、コードをリダイレクトするベースURLを設定します。
  // 例: あなたのウェブサイトのコード引き換えページなど
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
        print('対象コードが見つかりました: ${_targetCode!.code}, URL: $_qrDataUrl'); // デバッグログ
      } else {
        _targetCode = null; // コードが見つからなかった場合
        print('利用可能な未使用のコードが見つかりませんでした。'); // デバッグログ
      }

      setState(() {
        _isLoading = false; // ロード完了
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コードの取得に失敗しました: $e')),
      );
      setState(() {
        _isLoading = false; // ロード完了（エラー時も）
      });
      print('コードの取得に失敗しました: $e'); // デバッグログ
    }
  }

  // コードを使用したとマークするメソッド
  Future<void> _markCodeAsUsed() async {
    if (_targetCode == null || _targetCode!.id == null) {
      print('対象コードがないか、IDがありません。');
      return;
    }
    try {
      final updatedCode = _targetCode!.copyWith(used: 1); // usedを1に設定
      await DbHelper.instance.updateCode(updatedCode);

      setState(() {
        _targetCode = updatedCode; // UIの表示を更新
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.codeMarkedAsUsedSuccess(_targetCode!.code))),
      );
      // コード使用後の動作（例：ページを閉じる、次のコードをロードするなど）
      // Navigator.pop(context, true); // 前の画面に更新を通知して戻る
      // または、次の利用可能なコードを自動でロードする場合
      // _loadAndPrepareCode();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.codeMarkedAsUsedFailed(e.toString()))),
      );
    }
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
        child: Text(
          localizations.noUsableCodesAvailable, // 利用可能なコードがない場合のメッセージ
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : Center(
        child: SingleChildScrollView( // QRコードが大きい場合のためにスクロール可能にする
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${localizations.codeNumberLabel}: ${_targetCode!.number}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.codeLabel}: ${_targetCode!.code}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              // QRコードの表示
              QrImageView(
                data: _qrDataUrl, // 生成したURLをQRコードデータとして渡す
                version: QrVersions.auto, // 自動でバージョンを決定
                size: 280.0, // QRコードのサイズ
                gapless: true, // QRコードの余白をなくす
                embeddedImage: const AssetImage('assets/images/app_icon.png'), // アプリアイコンを埋め込む場合 (TODO: app_icon.pngをassetsに追加)
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(60, 60),
                ),
                // エラー時のメッセージ
                errorStateBuilder: (cxt, err) {
                  return Center(
                    child: Text(
                      localizations.qrCodeGenerationError(err.toString()),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                _targetCode!.used == 1
                    ? localizations.codeStatusUsed
                    : localizations.codeStatusAvailable,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _targetCode!.used == 1 ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              if (_targetCode!.used == 0) // 未使用の場合のみボタンを表示
                ElevatedButton.icon(
                  onPressed: _markCodeAsUsed,
                  icon: const Icon(Icons.check_circle),
                  label: Text(localizations.markAsUsedButtonText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.green, // ボタンの背景色
                    foregroundColor: Colors.white, // テキストとアイコンの色
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
