class Utils {
  static String formatTimeStamp(int time) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    String dateStr =
        "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return dateStr;
  }
}
