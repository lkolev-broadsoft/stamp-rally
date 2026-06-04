class Event {
  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.checkpoints,
    required this.requiredStamps,
    required this.prizeMessage,
    required this.publicKeys,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final List<Checkpoint> checkpoints;
  final int requiredStamps;
  final String prizeMessage;
  final Map<String, String> publicKeys;
  final DateTime createdAt;

  int get stampsNeeded {
    if (requiredStamps == 0) {
      return checkpoints.length;
    }
    return requiredStamps;
  }

  Checkpoint? checkpointById(String checkpointId) {
    for (final checkpoint in checkpoints) {
      if (checkpoint.id == checkpointId) {
        return checkpoint;
      }
    }
    return null;
  }
}

class Checkpoint {
  const Checkpoint({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.order,
  });

  final String id;
  final String eventId;
  final String name;
  final String description;
  final int order;
}
