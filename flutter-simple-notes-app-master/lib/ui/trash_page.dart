import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_notes_app/helpers/my-utils.dart';
import 'package:simple_notes_app/helpers/dialog-helper.dart';
import 'package:simple_notes_app/models/note-item.dart';
import 'package:simple_notes_app/ui/components/my_note_list_tile.dart';
import 'package:simple_notes_app/ui/note_detail_page.dart';
import 'package:simple_notes_app/helpers/data-helper.dart';

import 'components/my_drawer.dart';

class TrashPage extends StatefulWidget {
  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NoteItem>>(
        future: DataHelper.getAllDeletedNotes(),
        builder: (context, AsyncSnapshot<List<NoteItem>> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Trash'),
                actions: _buildActionButtons(snapshot.data),
              ),
              body: _buildNoteList(snapshot.data),
              drawer: _buildDrawer(context),
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

  List<Widget> _buildActionButtons(List<NoteItem> notes) {
    if (notes.isEmpty) {
      return null;
    }

    return [
      FlatButton(
        textColor: Colors.white,
        onPressed: () {
          DialogHelper.showConfirm(
            context: context,
            title: 'Empty Trash',
            message:
                'Are you sure you want to permanently delete all notes in the trash?',
            onOKPressed: () async {
              await DataHelper.emptyTrash();
              Navigator.pop(context); // dismiss dialog
              setState(() {});
            },
          );
        },
        child: Text("Empty Trash"),
        shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
      )
    ];
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

  Widget _buildNoteList(List<NoteItem> notes) {
    if (notes.isEmpty) {
      return Center(child: Text('Trash is empty'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        var note = notes[index];
        return MyNoteListTile(
          key: ValueKey(note.id),
          note: note,
          onTap: () async {
            final NoteItem result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteDetailPage(noteId: note.id)),
            );
            if (result != null && result.deleted != 1) {
              final snackBar =
                  SnackBar(content: Text('Note has been restored!'));
              Scaffold.of(context).showSnackBar(snackBar);
            }

            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return MyDrawer(
        context: context,
        selectedIndex: 1,
        onTapNotes: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onTapTrash: () async {
          Navigator.pop(context);
        });
  }
}
