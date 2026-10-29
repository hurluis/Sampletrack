import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sample_event.dart';

/// Fuente remota: Cloud Firestore, colección `sample_events`.
/// Un documento por evento (el id del documento es el id del evento).
/// No captura errores: el Repository decide qué hacer cuando fallan.
class SampleEventRemoteService {
  SampleEventRemoteService(this.firestore);

  final FirebaseFirestore firestore;

  /// Todos los eventos (el listado calcula el estado de cada muestra con ellos).
  Future<List<SampleEvent>> getEvents() async {
    // Source.server: si no hay red lanza error (así se usa el fallback de Drift)
    final snapshot = await firestore
        .collection('sample_events')
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    return _toEvents(snapshot);
  }

  /// Solo los eventos de una muestra (se relacionan por sampleId).
  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final snapshot = await firestore
        .collection('sample_events')
        .where('sampleId', isEqualTo: sampleId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    return _toEvents(snapshot);
  }

  /// doc(event.id) y no doc(sampleId): cada evento es un documento propio.
  Future<void> saveEvent(SampleEvent event) async {
    await firestore
        .collection('sample_events')
        .doc(event.id)
        .set(event.toJson())
        .timeout(const Duration(seconds: 10));
  }

  List<SampleEvent> _toEvents(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final List<SampleEvent> events = [];
    for (final doc in snapshot.docs) {
      events.add(SampleEvent.fromJson(doc.data()));
    }
    return events;
  }
}
