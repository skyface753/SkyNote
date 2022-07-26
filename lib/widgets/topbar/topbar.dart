// TOPBAR in Main

import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter/material.dart';
import 'package:skynote/appwrite.dart';
import 'package:skynote/main.dart';
import 'package:skynote/models/base_paint_element.dart';
import 'package:skynote/models/note_book.dart';
import 'package:skynote/widgets/topbar/draw.dart';
import 'package:skynote/widgets/topbar/insert.dart';
import 'package:skynote/widgets/topbar/start.dart';

enum TopBarMenuList { start, insert, draw }

String _topBarMenuListToString(TopBarMenuList menu) {
  switch (menu) {
    case TopBarMenuList.start:
      return 'Start';
    case TopBarMenuList.insert:
      return 'Insert';
    case TopBarMenuList.draw:
      return 'Draw';
  }
}

class TopBarList extends StatelessWidget {
  final TopBarMenuList menuToDisplay;
  final TopBarMenuList selectedMenu;
  final ValueChanged<TopBarMenuList> onMenuSelected;

  const TopBarList(this.menuToDisplay, this.selectedMenu, this.onMenuSelected,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onMenuSelected(menuToDisplay);
      },
      child: Column(
        children: [
          Text(_topBarMenuListToString(menuToDisplay),
              style: TextStyle(
                  color: selectedMenu == menuToDisplay
                      ? Colors.blue
                      : Colors.white,
                  fontSize: 20)),
          selectedMenu == menuToDisplay
              ? Container(
                  height: 2,
                  width: 40,
                  color: Colors.blue,
                )
              : Container(),
        ],
      ),
    );
  }
}

class TopBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<PaintElement>? paintElements;
  final List<Forms> formItems;
  final Forms selectedForm;
  final Offset offset;
  final Paint currentPaint;
  final List<Background> backgroundItems;
  final NoteBook noteBook;
  final CanvasState canvasState;
  final double currScale;
  final SelectionModes currentSelectionMode;
  final Paint selectedPaint;
  final bool darkMode;
  final ValueChanged<Forms> onChangeForm;
  final ValueChanged<Background> onChangeBackground;
  final VoidCallback onChangeEraseMode;
  final VoidCallback onChangeLassoMode;
  final VoidCallback onImagePicker;
  final VoidCallback onSave;
  final VoidCallback onVerify;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGoToHome;
  final ValueChanged<String> onCreateTextElement;
  final ValueChanged<String> onImagePaste;
  final ValueChanged<SelectionModes> onChangeSelectionMode;
  final ValueChanged<Paint> onChangePaint;
  final VoidCallback onDarkModeSwitch;

  TopBar(
    this.scaffoldKey,
    this.paintElements,
    this.formItems,
    this.selectedForm,
    this.offset,
    this.currentPaint,
    this.backgroundItems,
    this.noteBook,
    this.canvasState,
    this.currScale,
    this.currentSelectionMode,
    this.selectedPaint,
    this.darkMode, {
    Key? key,
    required this.onChangeForm,
    required this.onChangeBackground,
    required this.onChangeEraseMode,
    required this.onChangeLassoMode,
    required this.onImagePicker,
    required this.onSave,
    required this.onVerify,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGoToHome,
    required this.onCreateTextElement,
    required this.onImagePaste,
    required this.onChangeSelectionMode,
    required this.onChangePaint,
    required this.onDarkModeSwitch,
  }) : super(key: key);
  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  Storage appwriteStorage = AppWriteCustom().getAppwriteStorage();
  TextEditingController newTextFieldController = TextEditingController();

  void showFlashTopBar(BuildContext context, String text, bool success) {
    showFlash(
        context: context,
        duration: const Duration(seconds: 1, milliseconds: 500),
        builder: (_, controller) {
          return Flash(
              controller: controller,
              position: FlashPosition.top,
              behavior: FlashBehavior.floating,
              child: FlashBar(
                content: Text(text,
                    style:
                        TextStyle(color: success ? Colors.green : Colors.red)),
              ));
        });
  }

  TopBarMenuList _selectedMenu = TopBarMenuList.start;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      height: 95,
      width: double.infinity,
      // color: Theme.of(context).appBarTheme.backgroundColor,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(children: [
          TopBarList(TopBarMenuList.start, _selectedMenu, (menu) {
            setState(() {
              _selectedMenu = menu;
            });
          }),
          SizedBox(
            width: 10,
          ),
          TopBarList(TopBarMenuList.insert, _selectedMenu, (menu) {
            setState(() {
              _selectedMenu = menu;
            });
          }),
          SizedBox(
            width: 10,
          ),
          TopBarList(TopBarMenuList.draw, _selectedMenu, (menu) {
            setState(() {
              _selectedMenu = menu;
            });
          }),
        ]),
        Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () =>
                        widget.scaffoldKey.currentState?.openDrawer(),
                  ),
                  _selectedMenu == TopBarMenuList.draw
                      ? DrawTopBar(
                          widget.canvasState,
                          widget.currentPaint,
                          widget.formItems,
                          widget.selectedForm,
                          widget.onChangeEraseMode,
                          widget.onChangeForm,
                          widget.noteBook.paints,
                          widget.selectedPaint,
                          widget.onChangePaint,
                        )
                      : _selectedMenu == TopBarMenuList.insert
                          ? InsertTopBar(
                              onCreateTextElement: widget.onCreateTextElement,
                              onImagePaste: widget.onImagePaste)
                          : _selectedMenu == TopBarMenuList.start
                              ? StartTopBar(
                                  canvasState: widget.canvasState,
                                  paintElements: widget.paintElements,
                                  backgroundItems: widget.backgroundItems,
                                  onGoToHome: widget.onGoToHome,
                                  noteBook: widget.noteBook,
                                  currentSelectionMode:
                                      widget.currentSelectionMode,
                                  darkMode: widget.darkMode,
                                  onChangeBackground: widget.onChangeBackground,
                                  onChangeSelectionMode:
                                      widget.onChangeSelectionMode,
                                  onImagePicker: widget.onImagePicker,
                                  onSave: widget.onSave,
                                  onVerify: widget.onVerify,
                                  onZoomIn: widget.onZoomIn,
                                  onZoomOut: widget.onZoomOut,
                                  onDarkModeSwitch: widget.onDarkModeSwitch,
                                )
                              : Container(),
                ],
              ),
            ))
      ]),
    );
  }
}
