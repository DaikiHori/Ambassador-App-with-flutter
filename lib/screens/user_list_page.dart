// lib/screens/user_list_page.dart

import 'package:flutter/material.dart';
import '../db_helper.dart';   // DbHelperをインポート
import '../models/user.dart';  // Userモデルをインポート
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用
import 'add_user_page.dart'; // AddUserPageへ遷移するため

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> _users = []; // ユーザーのリスト
  bool _isLoading = true; // データロード中かどうかのフラグ

  @override
  void initState() {
    super.initState();
    _loadUsers(); // ページ初期化時にユーザーをロード
  }

  // データベースからユーザーのリストをロードするメソッド
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true; // ロード開始
    });
    try {
      final loadedUsers = await DbHelper.instance.getUsers(); // DbHelperからユーザーを取得
      setState(() {
        _users = loadedUsers; // 取得したリストを更新
        _isLoading = false; // ロード完了
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーのロードに失敗しました: $e')),
      );
      setState(() {
        _isLoading = false; // ロード完了（エラー時も）
      });
    }
  }

  // ユーザーを削除するメソッド (任意で追加)
  Future<void> _deleteUser(int id, String name) async {
    final localizations = AppLocalizations.of(context)!;
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteConfirmTitle),
          content: Text(localizations.deleteUserMessage(name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelButtonText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.deleteButtonText),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await DbHelper.instance.deleteUser(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.userDeletedSuccess(name))),
        );
        _loadUsers(); // リストを再ロードしてUIを更新
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.userDeleteFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.userListPageTitle), // ページのタイトル
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ロード中はプログレスインジケータ
          : _users.isEmpty
          ? Center(
        child: Text(
          localizations.noUsersMessage, // ユーザーがいない場合のメッセージ
          style: const TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card( // 各ユーザーをカードで表示
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                user.name,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              // 削除ボタンをtrailingに配置
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(user.id!, user.name),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ユーザー追加ページに遷移
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );
          // 新しいユーザーが追加された場合はリストを再ロード
          if (result == true) {
            _loadUsers();
          }
        },
        tooltip: localizations.addUsersButtonTooltip, // ツールチップ
        child: const Icon(Icons.add), // 追加アイコン
      ),
    );
  }
}
