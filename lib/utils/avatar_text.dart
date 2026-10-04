import '../models/player.dart';

String buildAvatarText(List<Player> players, int playerIndex) {
  if (playerIndex < 0 || playerIndex >= players.length) {
    return '?';
  }

  final String targetName = players[playerIndex].name.trim();
  if (targetName.isEmpty) return '?';

  final String targetUpper = targetName.toUpperCase();
  final List<int> candidateLengths = [1, 2, 3]
      .where((len) => len <= targetUpper.length)
      .toList();
  int chosenLength = candidateLengths.isNotEmpty ? candidateLengths.first : 1;

  bool hasDuplicateWithLength(int length) {
    final prefix = targetUpper.substring(0, length);
    for (int i = 0; i < players.length; i++) {
      if (i == playerIndex) continue;
      final otherName = players[i].name.trim();
      if (otherName.isEmpty) continue;
      final otherUpper = otherName.toUpperCase();
      final otherPrefixLength =
          length <= otherUpper.length ? length : otherUpper.length;
      final otherPrefix = otherUpper.substring(0, otherPrefixLength);
      if (otherPrefix == prefix) {
        return true;
      }
    }
    return false;
  }

  for (final length in candidateLengths) {
    chosenLength = length;
    if (!hasDuplicateWithLength(length)) {
      return targetUpper.substring(0, length);
    }
  }

  final fallbackPrefix = targetUpper.substring(0, chosenLength);
  int occurrence = 1;
  for (int i = 0; i < playerIndex; i++) {
    final otherName = players[i].name.trim();
    if (otherName.isEmpty) continue;
    final otherUpper = otherName.toUpperCase();
    final otherPrefixLength =
        chosenLength <= otherUpper.length ? chosenLength : otherUpper.length;
    final otherPrefix = otherUpper.substring(0, otherPrefixLength);
    if (otherPrefix == fallbackPrefix) {
      occurrence++;
    }
  }

  return '$fallbackPrefix$occurrence';
}
