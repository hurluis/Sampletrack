import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sample_event.dart';

/// Lee y escribe los eventos en Cloud Firestore (colección `sample_events`).
/// No captura errores: se propagan al repositorio, que decide qué hacer.
class SampleEventRemoteService {
  SampleEventRemoteService(this.firestore);

  final FirebaseFirestore firestore;

  static const _timeout = Duration(seconds: 10);

  /// Todos los eventos de la colección.
  Future<List<SampleEvent>> getEvents() async {
    final snapshot = await firestore
        .collection('sample_events')
        .get(const GetOptions(source: Source.server)) // sin caché de Firestore
        .timeout(_timeout);
    return snapshot.docs.map((doc) => _fromData(doc.data())).toList();
  }

  /// Eventos de una muestra. Sin orderBy (evita índice compuesto): ordena el repositorio/UI.
  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final snapshot = await firestore
        .collection('sample_events')
        .where('sampleId', isEqualTo: sampleId)
        .get(const GetOptions(source: Source.server))
        .timeout(_timeout);
    return snapshot.docs.map((doc) => _fromData(doc.data())).toList();
  }

  /// Un documento por evento: el id del documento es el id del evento.
  Future<void> saveEvent(SampleEvent event) {
    // ponytail: si vence el timeout el set queda en cola y puede llegar luego; usar runTransaction si se necesita atomicidad
    return firestore
        .collection('sample_events')
        .doc(event.id)
        .set({
          'id': event.id,
          'sampleId': event.sampleId,
          'type': event.type,
          'createdAt': Timestamp.fromDate(event.createdAt),
        })
        .timeout(_timeout);
  }

  SampleEvent _fromData(Map<String, dynamic> data) {
    return SampleEvent(
      id: data['id'] as String,
      sampleId: data['sampleId'] as String,
      type: data['type'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
