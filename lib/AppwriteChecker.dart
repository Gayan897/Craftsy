// ignore: file_names
import 'package:craft/appwriter_initializer.dart';

class AppwriteChecker {
  static bool isInitialized() {
    return AppwriteInitializer.client.endPoint.isNotEmpty;
  }
}
