import '../local/sample_event_local_datasource.dart';
import '../models/sample_event.dart';
import '../models/sample_status.dart';
import '../services/sample_event_remote_service.dart';

class EventsResult {
  const EventsResult(this.events, {required this.fromLocal});

  final List<SampleEvent> events;
  final bool fromLocal;
}

class InvalidTransitionException implements Exception {
  InvalidTransitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SampleEventRepository {
  SampleEventRepository({required this.local, required this.remote});

  final SampleEventLocalDatasource local;
  final SampleEventRemoteService remote;

  Future<EventsResult> getAllEvents() async {
    List<SampleEvent> events;
    try {
      events = await remote.getEvents();
    } catch (_) {
      return EventsResult(await local.getAllEvents(), fromLocal: true);
    }
    await local.saveEvents(events);
    return EventsResult(events, fromLocal: false);
  }

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

    await remote.saveEvent(event);
    await local.saveEvent(event);
    return event;
  }
}
