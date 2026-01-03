class TopicTag {
  int? id;
  final String tagName;

  TopicTag({this.id, required this.tagName});

  Map<String, dynamic> toMap() => {'tag': tagName};

  factory TopicTag.fromMap(Map<String, dynamic> map) =>
      TopicTag(id: map['id'] as int, tagName: map['tag'] as String);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TopicTag && tagName == other.tagName);
  }

  @override
  int get hashCode => tagName.hashCode;
}
