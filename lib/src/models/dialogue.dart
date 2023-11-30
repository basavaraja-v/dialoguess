class Dialogue {
  final String imageUrl;
  final List<String> options;
  final int rightOptionIndex;
  final int level;

  Dialogue({
    required this.imageUrl,
    required this.options,
    required this.rightOptionIndex,
    required this.level,
  });

  factory Dialogue.fromMap(Map<String, dynamic> map, int level) {
    return Dialogue(
      imageUrl: map['imageUrl'],
      options: List<String>.from(map['options']),
      rightOptionIndex: map['rightOptionIndex'],
      level: level,
    );
  }

  // Add a toMap method if needed for uploading data to Firestore
}
