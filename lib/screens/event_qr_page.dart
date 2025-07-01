// lib/screens/event_qr_page.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QRコード生成ライブラリをインポート
import 'package:flutter/services.dart'; // クリップボード操作用
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用

class EventQrPage extends StatefulWidget {
  final String eventName; // イベント名
  final String? eventUrl; // イベントURL (nullable)

  const EventQrPage({
    super.key,
    required this.eventName,
    this.eventUrl
  });

  @override
  State<EventQrPage> createState() => _EventQrPageState();
}

class _EventQrPageState extends State<EventQrPage> {

  // URLをクリップボードにコピーするメソッド
  Future<void> _copyUrlToClipboard(String urlText) async {
    await Clipboard.setData(ClipboardData(text: urlText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copiedUrlMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.eventQrPageTitle(widget.eventName)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // URLが表示されていない、または空の場合
              if (widget.eventUrl == null || widget.eventUrl!.isEmpty)
                Text(
                  localizations.noUrlAvailable, // URLがない場合のメッセージ
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              else // URLがある場合
                GestureDetector( // URLをタップしてコピーできるように
                  onTap: () => _copyUrlToClipboard(widget.eventUrl!),
                  child: SelectableText( // URLは選択可能にする
                    widget.eventUrl!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent, decoration: TextDecoration.underline),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // QRコードの表示
              if (widget.eventUrl != null && widget.eventUrl!.isNotEmpty)
                QrImageView(
                  data: widget.eventUrl!, // イベントURLをQRコードデータとして渡す
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width * 0.7, // 画面幅の70%を使用
                  gapless: true,
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: const Size(60, 60),
                  ),
                  errorStateBuilder: (cxt, err) {
                    return Center(
                      child: Text(
                        localizations.qrCodeGenerationError(err.toString()),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                )
              else
              // URLがない場合はQRコードの代わりにメッセージを表示
                Text(
                  localizations.noQrCodeAvailable, // QRコードがない場合のメッセージ
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
