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
}
