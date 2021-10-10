class Memo {
  Memo(this.title, this.lastEdit, this.text);
  String title;
  String lastEdit;
  String text;

  Map toMap() {
    return {
      "title": title,
      "lastEdit": lastEdit,
      "text": text,
    };
  }

  void edited() {
    final datetime = DateTime.now();

    if (datetime.minute >= 10) {
      lastEdit = "${datetime.year}/${datetime.month}/${datetime.day}  ${datetime.hour}:${datetime.minute}";
    } else {
      String minute = "0${datetime.minute}";
      lastEdit = "${datetime.year}/${datetime.month}/${datetime.day}  ${datetime.hour}:$minute";
    }
  }
}