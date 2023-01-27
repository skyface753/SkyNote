import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';

class AllOnlineImagesScreen extends StatefulWidget {
  const AllOnlineImagesScreen({Key? key}) : super(key: key);

  @override
  AllOnlineImagesScreenState createState() => AllOnlineImagesScreenState();
}

class ImageList {
  String id;
  String name;
  Uint8List image;

  ImageList(this.id, this.name, this.image);
}

class AllOnlineImagesScreenState extends State<AllOnlineImagesScreen> {
  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();

  Future<List<File>> getImages() async {
    List<File> files = await appwriteStorage
        .listFiles(bucketId: imageStorageId)
        .then((value) => value.files);
    return files;
  }

  Future<Uint8List> getSingleImage(String id) async {
    Uint8List image = await appwriteStorage.getFileDownload(
        bucketId: imageStorageId, fileId: id);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All online images'),
          actions: [
            //Delete all images
            IconButton(
              onPressed: () async {
                //Confirm delete
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete all images'),
                        content: const Text(
                            'Are you sure you want to delete all images?'),
                        actions: [
                          ElevatedButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Delete'),
                            onPressed: () async {
                              //Delete all images
                              List<File> files = await getImages();
                              for (File file in files) {
                                await appwriteStorage.deleteFile(
                                    bucketId: imageStorageId, fileId: file.$id);
                              }
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.delete),
            ),
            //Refresh button
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getImages(),
          builder: (context, AsyncSnapshot<List<File>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: getSingleImage(snapshot.data![index].$id),
                      builder:
                          (context, AsyncSnapshot<Uint8List> snapshotImage) {
                        return Card(
                          child: ListTile(
                            title: Text(snapshot.data![index].name),
                            subtitle: Text(snapshot.data![index].$id),
                            leading: snapshotImage.hasData
                                ? Image.memory(snapshotImage.data!)
                                : const CircularProgressIndicator(),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                //Confirm delete
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete image'),
                                        content: const Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: [
                                          ElevatedButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text('Delete'),
                                            onPressed: () async {
                                              await appwriteStorage.deleteFile(
                                                  bucketId: imageStorageId,
                                                  fileId: snapshot
                                                      .data![index].$id);
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ),
                        );
                      });
                },
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
