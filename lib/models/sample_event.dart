/// Evento de procesamiento de una muestra. Se relaciona con ella por [sampleId].
/// No guarda tipo, origen ni prioridad de la muestra: eso viene de la shell.
class SampleEvent {
  const SampleEvent({
    required this.id,
    required this.sampleId,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String sampleId;
  final String type;
  final DateTime createdAt;

  factory SampleEvent.fromJson(Map<String, dynamic> json) {
    return SampleEvent(
      id: json['id'] as String,
      sampleId: json['sampleId'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // createdAt en UTC para que no dependa de la zona horaria del dispositivo.
  Map<String, dynamic> toJson() => {
        'id': id,
        'sampleId': sampleId,
        'type': type,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };
}
