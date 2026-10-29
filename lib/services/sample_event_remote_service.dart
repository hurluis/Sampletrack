import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sample_event.dart';

class SampleEventRemoteService {
  SampleEventRemoteService(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<SampleEvent>> getEvents() async {
    final snapshot = await firestore
        .collection('sample_events')
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    return _toEvents(snapshot);
  }

  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final snapshot = await firestore
        .collection('sample_events')
        .where('sampleId', isEqualTo: sampleId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    return _toEvents(snapshot);
  }

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
