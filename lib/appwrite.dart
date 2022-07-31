import 'package:appwrite/appwrite.dart';

Client appwriteClient = Client();
Storage appwriteStorage = Storage(appwriteClient);
Account appwriteAccount = Account(appwriteClient);

class AppWriteCustom {
  static void initAppwrite() {
    appwriteClient
        .setEndpoint('https://appwrite.skyface.de/v1')
        .setProject('62e2a90e7db1bd7b69ab');
  }

  getAppwriteStorage() {
    return appwriteStorage;
  }

  getAppwriteAccount() {
    return appwriteAccount;
  }
}
