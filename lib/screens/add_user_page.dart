// lib/screens/add_user_page.dart

import 'package:flutter/material.dart';
import '../db_helper.dart';   // DbHelperをインポート
import '../models/user.dart';  // Userモデルをインポート
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>(); // フォームのキー
  final TextEditingController _nameController = TextEditingController(); // ユーザー名入力用

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ユーザーをデータベースに一括保存するメソッド
  Future<void> _saveUsers() async {
    if (_formKey.currentState!.validate()) {
      final String rawNames = _nameController.text.trim();
      final List<String> parsedNames = rawNames
          .split(RegExp(r'[\n,]')) // 改行またはカンマで分割
          .map((name) => name.trim()) // 各名前の前後空白を削除
          .where((name) => name.isNotEmpty) // 空の文字列を除外
          .toSet() // 重複を排除 (入力文字列レベルでの重複)
          .toList();

      if (parsedNames.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.userNameRequired)),
        );
        return; // 名前がない場合は保存を中断
      }

      final dbHelper = DbHelper.instance;
      int insertedCount = 0;
      int skippedCount = 0;
      List<String> skippedNames = [];

      try {
        // 既存のユーザー名を一度取得し、セットにして高速な重複チェックを行う
        final existingUsers = await dbHelper.getUsers();
        final existingUserNames = existingUsers.map((user) => user.name).toSet();

        for (final name in parsedNames) {
          if (existingUserNames.contains(name)) {
            skippedCount++;
            skippedNames.add(name);
            continue; // 既に存在する場合はスキップ
          }

          final userToSave = User(name: name);
          await dbHelper.insertUser(userToSave);
          insertedCount++;
        }

        if (!mounted) return;
        String message;
        if (insertedCount > 0 && skippedCount == 0) {
          message = AppLocalizations.of(context)!.usersSavedSuccess(insertedCount);
        } else if (insertedCount > 0 && skippedCount > 0) {
          message = AppLocalizations.of(context)!.usersSavedWithSkip(insertedCount, skippedNames.join(', '));
        } else if (insertedCount == 0 && skippedCount > 0) {
          message = AppLocalizations.of(context)!.usersSkippedAll(skippedNames.join(', '));
        } else {
          message = AppLocalizations.of(context)!.noUsersToSave;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context, true); // 前の画面に戻り、更新があったことを伝える
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.userSaveFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addUserPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                maxLines: null, // 複数行を可能にする
                keyboardType: TextInputType.multiline, // 改行キーを表示
                decoration: InputDecoration(
                  labelText: localizations.userNameLabel,
                  hintText: localizations.userNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  final String rawNames = value?.trim() ?? '';
                  final List<String> parsedNames = rawNames
                      .split(RegExp(r'[\n,]'))
                      .map((name) => name.trim())
                      .where((name) => name.isNotEmpty)
                      .toList();
                  if (parsedNames.isEmpty) {
                    return localizations.userNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveUsers,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  localizations.saveButtonText,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
