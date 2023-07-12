/*
 * esc_pos_utils
 * Created Ignacio Correa
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:esc_pos_utils/src/commands.dart';
import 'dart:convert';

class PDF417Size {
  const PDF417Size(this.value);
  final int value;

  static const size2 = PDF417Size(0x02);
  static const size3 = PDF417Size(0x03);
  static const size4 = PDF417Size(0x04);
  static const size5 = PDF417Size(0x05);
  static const size6 = PDF417Size(0x06);
  static const size7 = PDF417Size(0x07);
  static const size8 = PDF417Size(0x08);
}

class PDF417SizeCol {
  const PDF417SizeCol(this.value);
  final int value;

  static const size0 = PDF417SizeCol(0x00);
  static const size1 = PDF417SizeCol(0x01);
  static const size2 = PDF417SizeCol(0x02);
  static const size3 = PDF417SizeCol(0x04);
  static const size4 = PDF417SizeCol(0x08);
  static const size5 = PDF417SizeCol(0x0e);
  static const size6 = PDF417SizeCol(0x14);
  static const size7 = PDF417SizeCol(0x1a);
  static const size8 = PDF417SizeCol(0x1e);
}

class PDF417SizeRow {
  const PDF417SizeRow(this.value);
  final int value;

  static const size0 = PDF417SizeRow(0x00);
  static const size1 = PDF417SizeRow(0x03);
  static const size2 = PDF417SizeRow(0x06);
  static const size3 = PDF417SizeRow(0x12);
  static const size4 = PDF417SizeRow(0x18);
  static const size5 = PDF417SizeRow(0x20);
  static const size6 = PDF417SizeRow(0x40);
  static const size7 = PDF417SizeRow(0x48);
  static const size8 = PDF417SizeRow(0x5A);
}

/// PDF417 Correction level
/// from 0.01 to 4.00. Default is 0.10 (10%)
class PDF417Correction {
  const PDF417Correction(this.value);
  final double value;

  /// Level L: Recovery Capacity 10%
  static const L = PDF417Correction(0.1);

  /// Level M: Recovery Capacity 50%
  static const M = PDF417Correction(0.5);

  /// Level H: Recovery Capacity 100%
  static const H = PDF417Correction(1);

  /// Level H2: Recovery Capacity 200%
  static const H2 = PDF417Correction(2);

  /// Level H3: Recovery Capacity 300%
  static const H3 = PDF417Correction(3);

  /// Level H4: Recovery Capacity 400%
  static const H4 = PDF417Correction(4);
}

class PDF417Code {
  List<int> bytes = <int>[];

  PDF417Code(String text, Map<Object, Object> map,
      {PDF417Size sizeW = PDF417Size.size2,
      PDF417Size sizeH = PDF417Size.size2,
      PDF417SizeCol sizeCol = PDF417SizeCol.size0,
      PDF417SizeRow sizeRow = PDF417SizeRow.size0,
      PDF417Correction level = PDF417Correction.L}) {
    // Sets the number of columns of the data area for PDF417
    // pL pH cn fn n (fn=65), 0<=n<=30, n=0 specifies automatic processing
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x41] + [sizeCol.value];

    // Sets the number of rows of data area for PDF417
    // pL pH cn fn n (fn=66), 3<=n<=90, n=0 specifies automatic processing
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x42] + [sizeRow.value];

    // Sets the module width of one PDF417 symbol to n dots
    // pL pH cn fn n (fn=67), 2<=n<=8
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x43] + [sizeW.value];

    // Sets the PDF417 module height
    // pL pH cn fn n (fn=68), 2<=n<=8
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x44] + [sizeH.value];

    // Sets the error correction level for PDF417 symbols
    // pL pH cn fn m n (fn=69), m = 48,49, 48<=n<=56 (when m=48 [0x30] is specified) or 1<=n<=40 (when m=49 [0x31] is specified)
    int ecInt = (level.value * 10).ceil();
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x45, 0x31] + [ecInt];

    // Stores symbol data in the PDF417 symbol storage area.
    List<int> textBytes = latin1.encode(text);
    // pL pH cn fn n (fn=80)
    bytes += cPDF417Header.codeUnits + [textBytes.length + 3, 0x00, 0x30, 0x50, 0x30];
    bytes += textBytes;

    // Prints the PDF417 symbol data in the symbol storage area
    // pL pH cn fn n (fn=81)
    bytes += cPDF417Header.codeUnits + [0x03, 0x00, 0x30, 0x51, 0x30];
  }
}
