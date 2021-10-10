import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mark_ink/domain/memo.dart';
import 'package:mark_ink/main_page/main_model.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final mainModel = context.read(mainProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer(builder: (context, watch, child) {
            final currentMemoIndex = watch(mainProvider).currentMemoIndex;
            final memoList = watch(mainProvider).memoList;

            if (memoList.isNotEmpty) {
              return Text("Mark ink  [ ${memoList[currentMemoIndex].title} ]");
            } else {
              return const Text("Mark ink");
            }
          }),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                mainModel.saveMemo();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Preview",
              ),
              Tab(
                text: "Code",
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Consumer(builder: (context, watch, child) {

            final memoList = watch(mainProvider).memoList;
            final titleList = watch(mainProvider).memoList.map((Memo memo) {
              return memo.title;
            }).toList();

            return ListView(
              children: [
                Container(
                  color: Colors.teal,
                  child: DrawerHeader(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.edit),
                            ),
                            Text(
                              "Mark ink",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_comment),
                  title: const Text("Add memo"),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {

                        final nameTextController = TextEditingController();

                        return AlertDialog(
                          title: const Text("新しいメモの作成"),
                          content: SizedBox(
                            width: 200,
                            height: 150,
                            child: Column(
                              children: [
                                const Text("メモの名前は既存のメモと被らないようにしてください。"),
                                TextField(
                                  controller: nameTextController,
                                  maxLength: 40,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text("cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: const Text("ok"),
                              onPressed: () {
                                if (titleList.contains(nameTextController.text)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("同じ名前のメモが存在します。"),
                                      duration: Duration(seconds: 4),
                                    )
                                  );
                                } else if (nameTextController.text == "") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("名前が空欄です。"),
                                        duration: Duration(seconds: 4),
                                      )
                                  );
                                } else {
                                  Navigator.pop(context);
                                  mainModel.addMemo(nameTextController.text);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.comment),
                  title: const Text("memo"),
                  children: memoList.asMap().entries.map((memoMap) {
                    return ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(memoMap.value.title),
                      subtitle: Text(memoMap.value.lastEdit),
                      trailing: PopupMenuButton(
                        onSelected: (String value) {
                          if (value == "rename") {
                            showDialog(
                              context: context,
                              builder: (context) {

                                final nameTextController = TextEditingController();

                                return AlertDialog(
                                  title: const Text("名前の変更"),
                                  content: SizedBox(
                                    width: 200,
                                    height: 150,
                                    child: Column(
                                      children: [
                                        const Text("メモの名前は既存のメモと被らないようにしてください。"),
                                        TextField(
                                          controller: nameTextController,
                                          maxLength: 40,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("cancel"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("ok"),
                                      onPressed: () {
                                        if (titleList.contains(nameTextController.text)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("同じ名前のメモが存在します。"),
                                                duration: Duration(seconds: 4),
                                              )
                                          );
                                        } else if (nameTextController.text == "" && nameTextController.text != memoMap.value.title) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("名前が空欄です。"),
                                                duration: Duration(seconds: 4),
                                              )
                                          );
                                        } else {
                                          Navigator.pop(context);
                                          mainModel.renameMemo(memoMap.key, nameTextController.text);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (value == "copy") {
                            mainModel.copyMemo(memoMap.key);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("メモの削除"),
                                  content: const Text("メモを完全に削除します。\n削除すると復元できなくなります。\nよろしいですか？"),
                                  actions: [
                                    TextButton(
                                      child: const Text("cancel"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("ok"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        mainModel.deleteMemo(memoMap.key);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem(
                              child: Text("rename"),
                              value: "rename",
                            ),
                            PopupMenuItem(
                              child: Text("copy"),
                              value: "copy",
                            ),
                            PopupMenuItem(
                              child: Text("delete"),
                              value: "delete",
                            ),
                          ];
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        mainModel.openMemo(memoMap.key);
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }),
        ),
        body: Consumer(builder: (context, watch, child) {

          final editingController = watch(mainProvider).editingController;
          final viewText = watch(mainProvider).viewText;

          final memoEmpty = watch(mainProvider).memoList.isNotEmpty;

          return TabBarView(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints.expand(width: 100.0, height: 100.0),
                child: memoEmpty
                ? MarkdownBody(
                  data: viewText,
                )
                : const Center(
                  child: Text("open the memo and write Markdown here."),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.expand(width: 100.0, height: 100.0),
                child: memoEmpty
                    ? TextField(
                  controller: editingController,
                  expands: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "write Markdown here."
                  ),
                )
                : const Center(
                  child: Text("open the memo and write Markdown here."),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

}