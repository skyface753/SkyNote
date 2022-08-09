import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';

class AllOnlineImagesScreen extends StatefulWidget {
  @override
  _AllOnlineImagesScreenState createState() => _AllOnlineImagesScreenState();
}

class ImageList {
  String id;
  String name;
  Uint8List image;

  ImageList(this.id, this.name, this.image);
}

class _AllOnlineImagesScreenState extends State<AllOnlineImagesScreen> {
  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();

  Future<List<File>> getImages() async {
    List<File> files = await appwriteStorage
        .listFiles(bucketId: imageStorageID)
        .then((value) => value.files);
    return files;
  }

  Future<Uint8List> getSingleImage(String id) async {
    Uint8List image = await appwriteStorage.getFileDownload(
        bucketId: imageStorageID, fileId: id);
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('All online images'),
          actions: [
            //Delete all images
            IconButton(
              onPressed: () async {
                //Confirm delete
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete all images'),
                        content:
                            Text('Are you sure you want to delete all images?'),
                        actions: [
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Delete'),
                            onPressed: () async {
                              //Delete all images
                              List<File> files = await getImages();
                              for (File file in files) {
                                await appwriteStorage.deleteFile(
                                    bucketId: imageStorageID, fileId: file.$id);
                              }
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
              icon: Icon(Icons.delete),
            ),
            //Refresh button
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.refresh),
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
                                : CircularProgressIndicator(),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                //Confirm delete
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Delete image'),
                                        content: Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: [
                                          FlatButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Delete'),
                                            onPressed: () async {
                                              await appwriteStorage.deleteFile(
                                                  bucketId: imageStorageID,
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
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
