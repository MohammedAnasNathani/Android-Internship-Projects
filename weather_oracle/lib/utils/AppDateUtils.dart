import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, d MMM yyyy HH:mm:ss').format(dateTime);
  }

  static String formatHourlyTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDailyDate(DateTime dateTime) {
    return DateFormat('EEE, d MMM').format(dateTime);
  }
}