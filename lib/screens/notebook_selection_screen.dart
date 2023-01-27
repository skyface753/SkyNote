import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';

class NotebookSelectionScreen extends StatefulWidget {
  const NotebookSelectionScreen({Key? key}) : super(key: key);

  @override
  NotebookSelectionScreenState createState() => NotebookSelectionScreenState();
}

class NotebookSelectionScreenState extends State<NotebookSelectionScreen> {
  Account appwriteAccount = AppWriteCustom().getAppwriteAccount();
  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();

  @override
  void initState() {
    checkIsLoggedIn();

    super.initState();
  }

  void checkIsLoggedIn() async {
    bool isLoggedIn;
    await SharedPreferences.getInstance().then((value) => {
          isLoggedIn = value.getBool('isLoggedIn') ?? false,
          if (!isLoggedIn) {Navigator.pushReplacementNamed(context, '/login')}
        });
  }

  Future<List<File>> getNotebooks() async {
    List<File> files = await appwriteStorage
        .listFiles(bucketId: notebookStorageId, orderType: 'ASC')
        .then((value) => value.files);
    //Order files by $updatedAt (newest first)
    files.sort((a, b) => b.$updatedAt.compareTo(a.$updatedAt));
    return files;
    // for (File file in files) {
    //   notebooks[file.$id] = file.name;
    // }
    // return notebooks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select a notebook'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/online/images');
              },
              icon: const Icon(Icons.image),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                setState(() {});
              },
            ),
            IconButton(
                onPressed: () async {
                  try {
                    await appwriteAccount.deleteSession(sessionId: 'current');
                  } catch (e) {
                    print("Error in Logout from Appwrite");
                  }
                  await SharedPreferences.getInstance().then((value) => {
                        value.setBool('isLoggedIn', false),
                        Navigator.pushReplacementNamed(context, '/login')
                      });
                },
                icon: const Icon(Icons.exit_to_app)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => const InfiniteCanvasPage(
                noteBookId: null,
              ),
            );
            Navigator.pushReplacement(context, route);
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: getNotebooks(),
          builder: (context, AsyncSnapshot<List<File>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var date = DateTime.fromMillisecondsSinceEpoch(
                      snapshot.data!.elementAt(index).$updatedAt * 1000);
                  var readableDate =
                      RelativeDateTime(dateTime: DateTime.now(), other: date);
                  RelativeDateFormat relativeDateFormatter = RelativeDateFormat(
                    Localizations.localeOf(context),
                  );

                  return ListTile(
                    title: Text(
                        "${snapshot.data!.elementAt(index).name} / ${relativeDateFormatter.format(readableDate)}"),
                    onTap: () async {
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => InfiniteCanvasPage(
                          noteBookId: snapshot.data!.elementAt(index).$id,
                        ),
                      );
                      Navigator.push(context, route);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        showPlatformDialog(
                          context: context,
                          builder: (context) => BasicDialogAlert(
                            title: Text("Discard draft?"),
                            content: Text("Action cannot be undone."),
                            actions: <Widget>[
                              BasicDialogAction(
                                title: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              BasicDialogAction(
                                title: Text("Delete"),
                                onPressed: () async {
                                  await appwriteStorage
                                      .deleteFile(
                                          bucketId: notebookStorageId,
                                          fileId: snapshot.data!
                                              .elementAt(index)
                                              .$id)
                                      .then((value) => setState(() {}));
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                // },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
