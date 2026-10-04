class Player {
  final String id;
  final String name;
  final List<int> scores;

  Player({
    required this.id,
    required this.name,
    List<int>? scores,
  }) : scores = scores ?? [];

  int get totalScore => scores.fold(0, (sum, score) => sum + score);

  Player copyWith({
    String? id,
    String? name,
    List<int>? scores,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      scores: scores ?? List.from(this.scores),
    );
  }

  Player addScore(int score) {
    return copyWith(scores: [...scores, score]);
  }

  Player resetScores() {
    return copyWith(scores: []);
  }

  Map<String, dynamic> toJson() => {'id': id, 'n': name, 's': scores};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['n'] as String,
        scores: (json['s'] as List).map((e) => e as int).toList(),
      );
}
