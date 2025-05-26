import 'package:appwrite/appwrite.dart';

class AppwriteInitializer {
  static final Client client = Client();

  static Future<void> initialize() async {
    client
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('681ee1ba001cd0029007')
      ..setSelfSigned(status: true);
  }
}
