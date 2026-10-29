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
        sampleId: json['sample_id'] as String,
        type: json['type'] as String,
        createdAt: DateTime.parse(json['created_at'])
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sample_id': sampleId,
    'type': type,
    'created_at': createdAt.toIso8601String()
  }
}
