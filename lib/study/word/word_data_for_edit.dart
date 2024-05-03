class WordData {
  final String id;
  final String word;
  final String definition;
  final bool isFavorited;
  final String status;
  final int countLearn;

  WordData({
    required this.id,
    required this.word,
    required this.definition,
    required this.isFavorited,
    required this.status,
    required this.countLearn,
  });
}
