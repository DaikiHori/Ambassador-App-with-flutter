// lib/screens/add_event_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用
import '../db_helper.dart';       // DbHelperをインポート
import '../models/event.dart';     // Eventモデルをインポート
import '../models/code.dart';      // Codeモデルをインポート
import 'package:ambassador_app_with_flutter/l10n/app_localizations.dart'; // 多言語対応用

class AddEventPage extends StatefulWidget {
  // 編集するイベントのオブジェクト（新規追加の場合はnull）
  final Event? eventToEdit;

  const AddEventPage({super.key, this.eventToEdit});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>(); // フォームのキー

  final TextEditingController _nameController = TextEditingController(); // イベント名
  final TextEditingController _dateController = TextEditingController(); // 日付表示用
  final TextEditingController _codesController = TextEditingController(); // コード入力用 (編集時は非表示)
  final TextEditingController _urlController = TextEditingController(); // URL入力用

  // 編集モード時の初期データ
  Event? _currentEvent;
  DateTime? _selectedDate; // 選択された日付の実データ

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _currentEvent = widget.eventToEdit;
      _nameController.text = _currentEvent!.name;
      _selectedDate = _currentEvent!.date;
      _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDate!); // 日付表示を更新
      _urlController.text = _currentEvent!.url ?? ''; // URLも初期化

      // 編集モードではコードは触らないため、コントローラーは初期化しない（またはクリア）
      // ただし、UIからはTextFormField自体を非表示にする
      _codesController.text = ''; // 念のためクリア
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _codesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // 日付ピッカーを表示するメソッド
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // 初期表示日
      firstDate: DateTime(2000), // 選択可能な最初の日付
      lastDate: DateTime(2101),  // 選択可能な最後の日付
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDate!); // TextFormFieldに表示
      });
    }
  }

  // イベントとコードをデータベースに保存するメソッド
  Future<void> _saveEventWithCodes() async {
    if (_formKey.currentState!.validate()) {
      // 編集モードの場合、コードは更新しない
      // 新規作成モードの場合のみコードをパース
      List<String> parsedCodes = [];
      if (_currentEvent == null) { // 新規作成の場合のみコードを処理
        final String rawCodes = _codesController.text.trim();
        parsedCodes = rawCodes
            .split(RegExp(r'[\n,]')) // 改行またはカンマで分割
            .map((code) => code.trim()) // 各コードの前後空白を削除
            .where((code) => code.isNotEmpty) // 空の文字列を除外
            .toSet() // 重複を排除
            .toList();

        if (parsedCodes.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.eventCodesRequired)),
          );
          return; // コードがない場合は保存を中断
        }
      }

      // Eventオブジェクトを作成 (更新/新規作成共通)
      final Event eventToSave = Event(
        id: _currentEvent?.id, // 編集モードならIDを使用
        name: _nameController.text,
        date: _selectedDate!, // 日付が選択されていることをバリデーションで保証
        url: _urlController.text.isEmpty ? null : _urlController.text,
        // 新規作成の場合はparsedCodes.lengthを使用し、編集の場合は既存のcount/usableCountを維持
        count: _currentEvent == null ? parsedCodes.length : _currentEvent!.count,
        usableCount: _currentEvent == null ? parsedCodes.length : _currentEvent!.usableCount,
      );

      final dbHelper = DbHelper.instance;
      try {
        int eventId;
        String message;

        if (eventToSave.id == null) {
          // 新規イベントの追加
          eventId = await dbHelper.insertEvent(eventToSave);
          message = AppLocalizations.of(context)!.eventSavedSuccess(eventToSave.name);

          // 新規作成時のみコードを挿入
          for (int i = 0; i < parsedCodes.length; i++) {
            final code = Code(
              number: i + 1, // 連番
              eventId: eventId,
              code: parsedCodes[i],
              usable: 1, // 初期状態では利用可能
              used: 0,   // 初期状態では未利用
              userName: null,
            );
            await dbHelper.insertCode(code);
          }
        } else {
          // イベントの更新
          eventId = eventToSave.id!;
          await dbHelper.updateEvent(eventToSave);
          message = AppLocalizations.of(context)!.eventUpdatedSuccess(eventToSave.name);
          // 編集時はコードを触らないため、コードの更新・削除・追加ロジックはここには含めない
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context, true); // 前の画面に戻り、更新があったことを伝える
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.eventSaveFailed(e.toString()))),
        );
      }
    }
  }

  // イベントを削除するメソッド
  Future<void> _deleteEvent() async {
    final localizations = AppLocalizations.of(context)!;
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteConfirmTitle),
          content: Text(localizations.deleteEventMessage(_nameController.text)),
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
      if (_currentEvent?.id == null) return; // IDがない場合は削除できない

      try {
        await DbHelper.instance.deleteEvent(_currentEvent!.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.eventDeletedSuccess(_nameController.text))),
        );
        Navigator.pop(context, true); // 削除後、前の画面に戻り、更新があったことを伝える
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.eventDeleteFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEditMode = widget.eventToEdit != null; // 編集モードかどうか

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode
            ? localizations.editEventPageTitle
            : localizations.addEventPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // イベント名入力フィールド
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizations.eventNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.eventNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 日付選択フィールド
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: localizations.eventDateLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (_selectedDate == null) {
                    return localizations.eventDateRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // URL入力フィールド
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: localizations.eventUrlLabel,
                  hintText: localizations.eventUrlHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16.0),

              // コード入力フィールド (新規作成時のみ表示)
              if (!isEditMode) // <-- 編集モードでは非表示にする
                TextFormField(
                  controller: _codesController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: localizations.eventCodesLabel,
                    hintText: localizations.eventCodesHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    final String rawCodes = value?.trim() ?? '';
                    final List<String> parsedCodes = rawCodes
                        .split(RegExp(r'[\n,]'))
                        .map((code) => code.trim())
                        .where((code) => code.isNotEmpty)
                        .toSet()
                        .toList();
                    if (parsedCodes.isEmpty) {
                      return localizations.eventCodesRequired;
                    }
                    return null;
                  },
                ),
              if (!isEditMode) const SizedBox(height: 24.0), // コード入力フィールドがある場合のみスペース

              // 保存ボタンと削除ボタンを横並びにするRow
              Row(
                children: [
                  // 削除ボタン (編集モード時のみ表示)
                  if (isEditMode)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // 削除ボタンは赤色
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          localizations.deleteButtonText,
                          style: const TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  if (isEditMode) const SizedBox(width: 16.0), // ボタン間のスペース

                  // 保存ボタン
                  Expanded( // Expandedで残りスペースを埋める
                    child: ElevatedButton(
                      onPressed: _saveEventWithCodes,
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}