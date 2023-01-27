import 'package:appwrite/appwrite.dart';

Client appwriteClient = Client();
Storage appwriteStorage = Storage(appwriteClient);
Account appwriteAccount = Account(appwriteClient);

String notebookStorageId = "63d3c8530fe66d949fd9";
String imageStorageId = "63d3c8672251139de1ff";

class AppWriteCustom {
  static void initAppwrite() {
    appwriteClient
        .setEndpoint('https://appwrite.skyface.de/v1')
        .setProject('63d3c808075cb2536dc7');
  }

  getAppwriteStorage() {
    return appwriteStorage;
  }

  getAppwriteAccount() {
    return appwriteAccount;
  }
}
