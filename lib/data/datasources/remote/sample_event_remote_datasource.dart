import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_track_shell/models/sample_event.dart';

class SampleEventRemoteDatasource {
    final FirebaseFirestore firestore;

    SampleEventRemoteDatasource({ required this.firestore });

    Future<void> upsertNote(SampleEvent event) async {
        await firestore
            .collection('sample_events')
            .doc(event.id)
            .set(event.toJson());
    }
}
