import 'package:characters/characters.dart';

class Segment {
  int? id;
  final Characters text;
  final bool isKnown;

  Segment(this.id, this.text, this.isKnown);
}
