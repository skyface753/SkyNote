// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:skynote/config.dart';
// import 'package:skynote/show_dialog.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// class GoogleDriveSearch extends StatefulWidget {
//   @override
//   _GoogleDriveSearch createState() => _GoogleDriveSearch();
// }

// const _folderType = "application/vnd.google-apps.folder";

// class _GoogleDriveSearch extends State<GoogleDriveSearch> {
//   final googleSignIn = GoogleSignIn(clientId: config["clientID"], scopes: [
//     drive.DriveApi.driveScope,
//     drive.DriveApi.driveAppdataScope,
//     drive.DriveApi.driveReadonlyScope
//   ]);

//   // GoogleSignIn.standard(scopes: [
//   //   drive.DriveApi.driveAppdataScope,
//   //   // drive.DriveApi.driveFileScope,
//   //   drive.DriveApi.driveReadonlyScope
//   // ]);

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Google Drive Search"),
//         ),
//         body: _createBody(context),
//       ),
//     );
//   }

//   Widget _createBody(BuildContext context) {
//     return Column(
//       children: [
//         Center(child: _createButton("All file list", _allFileList)),
//         Center(child: _createButton("Root list", _root)),
//         Center(child: _createButton("Text files", _txt)),
//         Center(child: _createButton("Files in temp1 folder", _filesInFolder)),
//         Center(
//             child: _createButton("Files owned by other", _filesOwnedByOther)),
//         Center(child: _createButton("Shared files", _sharedFiles)),
//         Center(
//             child: ElevatedButton(
//           child: const Text("Upload Hidden File"),
//           onPressed: () {
//             _uploadToHidden();
//           },
//         )),
//       ],
//     );
//   }

//   Future<drive.FileList> _allFileList(drive.DriveApi driveApi) {
//     return driveApi.files.list(
//       spaces: 'drive',
//     );
//   }

//   Future<drive.FileList> _root(drive.DriveApi driveApi) {
//     return driveApi.files.list(
//       spaces: 'drive',
//       q: "'root' in parents",
//     );
//   }

//   Future<drive.FileList> _txt(drive.DriveApi driveApi) {
//     return driveApi.files.list(
//       spaces: 'drive',
//       q: "name contains '.txt'",
//     );
//   }

//   Future<drive.FileList> _filesInFolder(drive.DriveApi driveApi) async {
//     final folderId = await _getFolderId(driveApi, "temp1");
//     return driveApi.files.list(
//       spaces: 'drive',
//       q: "'$folderId' in parents",
//     );
//   }

//   Future<drive.FileList> _filesOwnedByOther(drive.DriveApi driveApi) async {
//     return driveApi.files.list(
//       spaces: 'drive',
//       q: "not 'me' in owners",
//     );
//   }

//   Future<drive.FileList> _sharedFiles(drive.DriveApi driveApi) async {
//     final list = await driveApi.files.list(
//       spaces: 'drive',
//       q: "'me' in owners",
//       $fields: "files(name, mimeType, shared)",
//     );

//     list.files?.removeWhere((element) => element.shared == false);
//     return list;
//   }

//   Future<drive.DriveApi?> _getDriveApi() async {
//     final googleUser = await googleSignIn.signIn();

//     if (googleUser != null) {
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//       final UserCredential loginUser =
//           await FirebaseAuth.instance.signInWithCredential(credential);

//       assert(loginUser.user?.uid == FirebaseAuth.instance.currentUser?.uid);
//     }

//     final headers = await googleUser?.authHeaders;
//     if (headers == null) {
//       await showMessage(context, "Sign-in first", "Error");
//       return null;
//     }

//     final client = GoogleAuthClient(headers);
//     final driveApi = drive.DriveApi(client);
//     return driveApi;
//   }

//   Future<String?> _getFolderId(
//     drive.DriveApi driveApi,
//     String folderName,
//   ) async {
//     try {
//       final found = await driveApi.files.list(
//         q: "mimeType = '$_folderType' and name = '$folderName'",
//         $fields: "files(id)",
//       );
//       final files = found.files;
//       if (files == null) {
//         return null;
//       }

//       if (files.isNotEmpty) {
//         return files.first.id;
//       }
//     } catch (e) {
//       print(e);
//     }
//     return null;
//   }

//   Widget _createButton(String title, Function(drive.DriveApi driveApi) query) {
//     return ElevatedButton(
//       onPressed: () async {
//         final driveApi = await _getDriveApi();
//         if (driveApi == null) {
//           return;
//         }

//         final fileList = await query(driveApi);
//         final files = fileList.files;
//         if (files == null) {
//           return showMessage(context, "Data not found", "");
//         }
//         await _showList(files);
//       },
//       child: Text(title),
//     );
//   }

//   Future<void> _showList(List<drive.File> files) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("List"),
//           content: Container(
//             width: MediaQuery.of(context).size.height - 50,
//             height: MediaQuery.of(context).size.height,
//             child: ListView.builder(
//               itemCount: files.length,
//               itemBuilder: (context, index) {
//                 final isFolder = files[index].mimeType == _folderType;

//                 return ListTile(
//                   leading: Icon(isFolder
//                       ? Icons.folder
//                       : Icons.insert_drive_file_outlined),
//                   title: Text(files[index].name ?? ""),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _uploadToHidden() async {
//     try {
//       // final driveApi = await _getDriveApi();
//       // driveApi
//       final driveApi = await _getDriveApi();
//       if (driveApi == null) {
//         return;
//       }
//       // Not allow a user to do something else
//       showGeneralDialog(
//         context: context,
//         barrierDismissible: false,
//         transitionDuration: const Duration(seconds: 2),
//         barrierColor: Colors.black.withOpacity(0.5),
//         pageBuilder: (context, animation, secondaryAnimation) => const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//       // Create data here instead of loading a file
//       const contents = "Technical Feeder";
//       final Stream<List<int>> mediaStream =
//           Future.value(contents.codeUnits).asStream().asBroadcastStream();
//       var media = drive.Media(mediaStream, contents.length);

//       var driveFile = drive.File();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       driveFile.name = "technical-feeder-$timestamp.txt";
//       driveFile.modifiedTime = DateTime.now().toUtc();
//       driveFile.parents = ["appDataFolder"];
//       final response =
//           await driveApi.files.create(driveFile, uploadMedia: media);
//       print(response);
//       print("HI");
//       var file = await driveApi.files.get(response.id!);
//     } finally {
//       // Remove a dialog
//       Navigator.pop(context);
//     }
//   }
// }

// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final _client = new http.Client();

//   GoogleAuthClient(this._headers);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     request.headers.addAll(_headers);
//     return _client.send(request);
//   }
// }
