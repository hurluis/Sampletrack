import '../local/sample_event_local_datasource.dart';
import '../models/sample_event.dart';
import '../models/sample_status.dart';
import '../services/sample_event_remote_service.dart';

/// Eventos obtenidos y su origen. [fromLocal] es true cuando Firestore falló y
/// se muestran los últimos eventos guardados en Drift.
class EventsResult {
  const EventsResult(this.events, {required this.fromLocal});

  final List<SampleEvent> events;
  final bool fromLocal;
}

/// La transición pedida no es la siguiente del flujo: no se persiste nada.
class InvalidTransitionException implements Exception {
  InvalidTransitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// UI -> Repository -> Firestore (remoto) -> Drift (caché local).
class SampleEventRepository {
  SampleEventRepository({required this.local, required this.remote});

  final SampleEventLocalDatasource local;
  final SampleEventRemoteService remote;

  /// Todos los eventos (el listado calcula el estado de cada muestra con ellos).
  /// Firestore primero; si falla, los últimos datos de Drift.
  Future<EventsResult> getAllEvents() async {
    List<SampleEvent> events;
    try {
      events = await remote.getEvents();
    } catch (_) {
      return EventsResult(await local.getAllEvents(), fromLocal: true);
    }
    await local.saveEvents(events); // actualiza la caché local
    return EventsResult(events, fromLocal: false);
  }

  /// Solo los eventos de [sampleId]. Firestore primero; si falla, Drift.
  Future<EventsResult> getEventsForSample(String sampleId) async {
    List<SampleEvent> events;
    try {
      events = await remote.getEventsForSample(sampleId);
    } catch (_) {
      final cached = await local.getEventsForSample(sampleId);
      return EventsResult(cached, fromLocal: true);
    }
    await local.saveEvents(events);
    return EventsResult(events, fromLocal: false);
  }

  /// Valida la transición, guarda en Firestore y solo entonces en Drift.
  /// Si Firestore falla lanza el error y el evento no queda confirmado.
  Future<SampleEvent> registerEvent(String sampleId, String type) async {
    final current = await getEventsForSample(sampleId);
    final error = validateTransition(currentStatus(current.events), type);
    if (error != null) {
      throw InvalidTransitionException(error);
    }

    final now = DateTime.now();
    final event = SampleEvent(
      id: '${sampleId}_${now.microsecondsSinceEpoch}',
      sampleId: sampleId,
      type: type,
      createdAt: now,
    );

    await remote.saveEvent(event); // si falla, no se escribe en Drift
    await local.saveEvent(event);
    return event;
  }
}
