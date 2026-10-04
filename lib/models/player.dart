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
}
