import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mark_ink/domain/memo.dart';

const String databaseName = "mark_ink_db";

final mainProvider = ChangeNotifierProvider<MainModel>(
      (ref) => MainModel()..initModel(),
);

class MainModel extends ChangeNotifier {
  List<Memo> memoList = [];

  int currentMemoIndex = 0;
  String viewText = "";
  TextEditingController editingController = TextEditingController();

  void initModel() async {
    await Hive.initFlutter();
    await Hive.openBox(databaseName);

    fetchAll();

    if (memoList.isNotEmpty) {
      openMemo(currentMemoIndex);
    }
  }

  void fetchAll() {
    Box box = Hive.box(databaseName);
    List getMemoList = box.get("memo") ?? [];

    memoList = [];

    if (getMemoList.isNotEmpty) {
      for (var memoMap in getMemoList) {
        memoList.add(Memo(memoMap["title"], memoMap["lastEdit"], memoMap["text"]));
      }
    }

    notifyListeners();
  }

  void updateDatabase() {
    List<Map> putMemoList = [];

    if (memoList.isNotEmpty) {
      for (var memo in memoList) {
        putMemoList.add(memo.toMap());
      }
    }

    Box box = Hive.box(databaseName);
    box.delete("memo");
    box.put("memo", putMemoList);

    fetchAll();
    notifyListeners();
  }

  void addMemo(String title) {
    Memo memo = Memo(title, "", "");
    memo.edited();

    memoList.add(memo);

    updateDatabase();
    notifyListeners();
  }

  void deleteMemo(int index) {
    memoList.removeAt(index);

    if (currentMemoIndex > index) {
      currentMemoIndex -= 1;
    } else if (currentMemoIndex == index) {
      currentMemoIndex = 0;
    }

    updateDatabase();
    notifyListeners();
  }

  void renameMemo(int index, String title) {
    memoList[index].title = title;

    updateDatabase();
    notifyListeners();
  }

  void copyMemo(int index) {

    Memo memo = Memo("${memoList[index].title} copy", memoList[index].lastEdit, memoList[index].text);
    memo.edited();
    memoList.add(memo);

    updateDatabase();
    notifyListeners();
  }

  void openMemo(int index) {
    currentMemoIndex = index;
    editingController.text = memoList[currentMemoIndex].text;
    viewText = editingController.text;

    notifyListeners();
  }

  void saveMemo() {
    if (memoList.isNotEmpty) {
      memoList[currentMemoIndex].text = editingController.text;
      viewText = editingController.text;
          
      memoList[currentMemoIndex].edited();

      updateDatabase();
      notifyListeners();
    }
  }
}
