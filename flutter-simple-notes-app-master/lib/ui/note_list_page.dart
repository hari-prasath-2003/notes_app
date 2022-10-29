import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_notes_app/models/note-item.dart';
import 'package:simple_notes_app/ui/my_search_delegate.dart';
import 'package:simple_notes_app/ui/trash_page.dart';
import 'package:simple_notes_app/ui/update_note_page.dart';
import 'package:simple_notes_app/helpers/data-helper.dart';
import 'add_note_page.dart';
import 'components/my_drawer.dart';
import 'components/my_note_list_tile.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final MySearchDelegate _searchDelegate = MySearchDelegate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NoteItem>>(
        future: DataHelper.getAllWithTruncatedContent(),
        builder: (context, AsyncSnapshot<List<NoteItem>> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Simple Notes App'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      await showSearch<String>(
                        context: context,
                        delegate: _searchDelegate,
                      );
                    },
                  ),
                ],
              ),
              body: _buildNoteList(snapshot.data),
              drawer: _buildDrawer(context),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _navigateToAddNotePage(context);
                },
                child: Icon(Icons.add),
              ),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text('Simple Notes App'),
                ),
                body: _buildLoadingScreen(context));
          }
        });
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 100,
      height: 100,
      child: new Column(
        children: [
          CircularProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.grey,
          ),
          Container(margin: EdgeInsets.only(top: 15), child: Text("Loading")),
        ],
      ),
    ));
  }

  _navigateToAddNotePage(BuildContext context) async {
    final NoteItem result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );

    if (result != null && result.title.isNotEmpty) {
      setState(() {});
    }
  }

  Widget _buildNoteList(List<NoteItem> notes) {
    if (notes.isEmpty) {
      return Center(child: Text('No Data'));
    }

    return ListView.builder(
        padding: EdgeInsets.all(4.0),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return MyNoteListTile(
            note: notes[index],
            onTap: () async {
              final NoteItem result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UpdateNotePage(noteId: notes[index].id)),
              );
              setState(() {});
            },
          );
        });
  }

  Widget _buildDrawer(BuildContext context) {
    return MyDrawer(
        context: context,
        selectedIndex: 0,
        onTapNotes: () {
          Navigator.pop(context);
        },
        onTapTrash: () async {
          Navigator.pop(context); // close the drawer
          _navigateToTrashPage(context);
        });
  }

  _navigateToTrashPage(BuildContext context) async {
    final NoteItem result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrashPage()),
    );
  }
}
