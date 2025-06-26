// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ロケールサポート用
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 生成されたローカライズクラス
import 'package:ambassador_app_with_flutter/db_helper.dart'; // DbHelperをインポートして初期化
import 'screens/event_list_page.dart'; // EventListPageをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutterエンジンのバインディングを初期化
  await DbHelper.instance.database; // データベースを初期化（onCreateが呼ばれる）
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle, // アプリのタイトル
      theme: ThemeData(
        primarySwatch: Colors.blue, // テーマカラー
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // Material 3を有効にする
      ),
      // 多言語対応の設定
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // 英語をサポート
        Locale('ja'), // 日本語をサポート
      ],
      home: const EventListPage(), // トップページとしてEventListPageを設定
    );
  }
}
