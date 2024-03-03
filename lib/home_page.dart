import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapp/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Firestore
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  //open a dialog vox to add a note
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //button to save
          ElevatedButton(
              onPressed: () {
                //add a new note
                if (docID == null) {
                  firestoreService.addNote(textController.text);
                }

                //update existing note
                else {
                  firestoreService.updateNote(docID, textController.text);
                }

                //clear the text controller
                textController.clear();

                //close the box
                Navigator.pop(context);
              },
              child: const Text('Add'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.amber,
            title: const Text('NOTES'),
            elevation: 5,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: openNoteBox,
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getNotesStream(),
              builder: (context, snapshot) {
                //if we have data, get all the docs
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;

                  //display as a list
                  return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        //get each individual doc
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;

                        //get note from each doc
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        String noteText = data['note'];

                        //display as a list Tile
                        return ListTile(
                            title: Text(noteText),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //update button
                                IconButton(
                                    onPressed: () => openNoteBox(docID: docID),
                                    icon: Icon(Icons.edit)),
                                //delete button
                                IconButton(
                                    onPressed: () =>
                                        firestoreService.deleteNote(docID),
                                    icon: Icon(Icons.delete)),
                              ],
                            ));
                      });
                }
                //if there is no data
                else {
                  return const Text('no data');
                }
              })),
    );
  }
}
