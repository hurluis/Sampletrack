import 'package:sample_track_shell/local/sample_event_local_datasource.dart';
import 'package:sample_track_shell/services/sample_event_remote_service.dart';

import '../models/sample_event.dart';

/// Punto de inicio para coordinar las fuentes de datos del examen.
class SampleEventRepository {
  final SampleEventLocalDatasource local;
  final SampleEventRemoteService? remote;

  SampleEventRepository({ required this.local, this.remote });

  Future<List<SampleEvent?>> getEventsForSample(String sampleId) async {
    local.getEventsForSample(sampleId);
    // TODO: Retrieve remotes?
  }

  Future<void> registerEvent(SampleEvent event) async {
    // TODO: implementar el flujo definido en el enunciado.
    throw UnimplementedError();
  }
}
