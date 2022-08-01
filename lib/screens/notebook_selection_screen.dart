import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
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

  Future<Map<String, String>> getNotebooks() async {
    Map<String, String> notebooks = {};
    List<File> files = await appwriteStorage
        .listFiles(bucketId: '62e2afd619bea62ecafd')
        .then((value) => value.files);
    for (File file in files) {
      notebooks[file.name] = file.$id;
    }
    return notebooks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select a notebook'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                setState(() {});
              },
            ),
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
          builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data!.keys.elementAt(index)),
                    onTap: () async {
                      MaterialPageRoute route = MaterialPageRoute(
                        builder: (context) => InfiniteCanvasPage(
                          noteBookId: snapshot.data!.values.elementAt(index),
                        ),
                      );
                      Navigator.pushReplacement(context, route);
                    },
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
