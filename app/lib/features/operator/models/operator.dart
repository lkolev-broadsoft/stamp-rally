class Operator {
  const Operator({
    required this.id,
    required this.eventId,
    required this.checkpointId,
    required this.name,
    required this.pin,
    required this.keyId,
    required this.privateSeedBase64,
  });

  final String id;
  final String eventId;
  final String checkpointId;
  final String name;
  final String pin;
  final String keyId;
  final String privateSeedBase64;
}
