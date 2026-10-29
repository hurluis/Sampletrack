import 'sample.dart';
import 'sample_event.dart';

const List<String> eventFlow = [
  'RECEIVED',
  'PREPARED',
  'IN_ANALYSIS',
  'VALIDATED',
  'ARCHIVED',
];

const List<String> statusLabels = [
  'Recibida',
  'Preparada',
  'En análisis',
  'Validada',
  'Archivada',
];

const String noEventsLabel = 'Sin eventos';

const List<String> priorityOrder = ['Urgente', 'Alta', 'Normal'];

int flowIndex(String? type) {
  if (type == null) return -1;
  for (int i = 0; i < eventFlow.length; i++) {
    if (eventFlow[i] == type) return i;
  }
  return -1;
}

String statusLabel(String? type) {
  if (type == null) return noEventsLabel;
  final int index = flowIndex(type);
  return index == -1 ? type : statusLabels[index];
}

int progressPercent(String? type) {
  final int index = flowIndex(type);
  return index == -1 ? 0 : (index + 1) * 20;
}

SampleEvent? latestEvent(List<SampleEvent> events) {
  SampleEvent? latest;
  for (int i = 0; i < events.length; i++) {
    if (latest == null || events[i].createdAt.isAfter(latest.createdAt)) {
      latest = events[i];
    }
  }
  return latest;
}

String? currentStatus(List<SampleEvent> events) {
  final SampleEvent? latest = latestEvent(events);
  return latest?.type;
}

String? nextEventType(String? currentType) {
  final int next = flowIndex(currentType) + 1;
  return next < eventFlow.length ? eventFlow[next] : null;
}

String? validateTransition(String? currentType, String newType) {
  final String? next = nextEventType(currentType);
  if (next == null) {
    return 'La muestra ya está archivada: no admite más eventos.';
  }
  if (newType != next) {
    return 'Transición inválida: desde ${statusLabel(currentType)} '
        'solo se puede registrar ${statusLabel(next)}.';
  }
  return null;
}

List<SampleEvent> sortByDate(List<SampleEvent> events) {
  final List<SampleEvent> sorted = [];
  for (int i = 0; i < events.length; i++) {
    int position = sorted.length;
    while (position > 0 &&
        sorted[position - 1].createdAt.isAfter(events[i].createdAt)) {
      position--;
    }
    sorted.insert(position, events[i]);
  }
  return sorted;
}

List<SampleEvent> eventsOfSample(List<SampleEvent> events, String sampleId) {
  final List<SampleEvent> result = [];
  for (int i = 0; i < events.length; i++) {
    if (events[i].sampleId == sampleId) {
      result.add(events[i]);
    }
  }
  return result;
}

Map<String, String?> statusBySample(
  List<Sample> samples,
  List<SampleEvent> events,
) {
  final Map<String, String?> statuses = {};
  for (int i = 0; i < samples.length; i++) {
    final List<SampleEvent> own = eventsOfSample(events, samples[i].id);
    statuses[samples[i].id] = currentStatus(own);
  }
  return statuses;
}

Map<String, int> summaryByStatus(Map<String, String?> statuses) {
  final Map<String, int> summary = {noEventsLabel: 0};
  for (int i = 0; i < statusLabels.length; i++) {
    summary[statusLabels[i]] = 0;
  }
  for (String sampleId in statuses.keys) {
    final String label = statusLabel(statuses[sampleId]);
    summary[label] = (summary[label] ?? 0) + 1;
  }
  return summary;
}

int priorityRank(String priority) {
  for (int i = 0; i < priorityOrder.length; i++) {
    if (priorityOrder[i] == priority) return i;
  }
  return priorityOrder.length;
}

List<Sample> pendingValidation(
  List<Sample> samples,
  Map<String, String?> statuses,
) {
  final List<Sample> pending = [];
  for (int rank = 0; rank <= priorityOrder.length; rank++) {
    for (int i = 0; i < samples.length; i++) {
      final bool enAnalisis = statuses[samples[i].id] == 'IN_ANALYSIS';
      if (enAnalisis && priorityRank(samples[i].priority) == rank) {
        pending.add(samples[i]);
      }
    }
  }
  return pending;
}
