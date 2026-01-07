import 'package:khmer_text_vectorization/data/app_database.dart';
import 'package:khmer_text_vectorization/model/topic_tag.dart';

class SuggestTagsService {
  final Set<TopicTag> _suggestionTags = {};
  static SuggestTagsService instance = SuggestTagsService._constructor();
  SuggestTagsService._constructor();

  Future<void> addNewTag(TopicTag newTag) async {
    if (!_suggestionTags.contains(newTag)) {
      int id = await AppDatabase.instance.saveNewTag(newTag);
      newTag.id = id;
      _suggestionTags.add(newTag);
    }
  }

  Future<void> initSuggestTags() async {
    _suggestionTags.clear();
    _suggestionTags.addAll(await AppDatabase.instance.getAllTags());
  }

  Future<Set<TopicTag>> get suggestionTags async {
    if (_suggestionTags.isEmpty) {
      _suggestionTags.addAll(await AppDatabase.instance.getAllTags());
    }
    return _suggestionTags;
  }
}
