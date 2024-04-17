import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart'; // Import this for rootBundle

class PrinterTextFormatter {
  final List<LineText> _textList = [];

  void addLineText(LineText lineText) {
    _textList.add(lineText);
  }

  void addHeading(String text) {
    _textList.add(LineText(
        type: LineText.TYPE_TEXT,
        content: text,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
        fontZoom: 2));
  }

  void addSubHeading(String text) {
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: text,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 1,
    ));
  }

  void addNameValue(String name, String value) {
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: name,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 0,
    ));
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: value,
      weight: 2,
      align: LineText.ALIGN_LEFT,
      x: 200,
      relativeX: 0,
      linefeed: 2,
    ));
  }

  void addRightValue(String text, String colon, String value) {
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: text,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 0,
    ));
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: colon,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 167,
      relativeX: 0,
      linefeed: 0,
    ));
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: value,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 300,
      relativeX: 0,
      linefeed: 0,
    ));
  }

  void addValue(String text, String colon, String value) {
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: text,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 0,
    ));
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: colon,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 150,
      relativeX: 0,
      linefeed: 0,
    ));
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: value,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 280,
      relativeX: 0,
      linefeed: 1,
    ));
  }

  void addText(String text) {
    _textList.add(LineText(
      type: LineText.TYPE_TEXT,
      content: text,
      weight: 1,
      align: LineText.ALIGN_LEFT,
      x: 0,
      relativeX: 0,
      linefeed: 1,
    ));
  }

  void addLineBreak() {
    _textList.add(LineText(linefeed: 1));
  }

  void addImage(Uint8List imageBytes) {
    String base64Image = base64Encode(imageBytes);
    _textList.add(LineText(
      type: LineText.TYPE_IMAGE,
      content: base64Image,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
  }

  List<LineText> generate() {
    return _textList;
  }
}
