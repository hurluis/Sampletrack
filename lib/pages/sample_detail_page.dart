import 'package:flutter/material.dart';

import '../models/sample.dart';
import '../models/sample_event.dart';
import '../models/sample_status.dart';
import '../repositories/sample_event_repository.dart';
import '../widgets/local_data_notice.dart';

class SampleDetailPage extends StatefulWidget {
  const SampleDetailPage({
    super.key,
    required this.sample,
    required this.repository,
  });

  final Sample sample;
  final SampleEventRepository repository;

  @override
  State<SampleDetailPage> createState() => _SampleDetailPageState();
}

class _SampleDetailPageState extends State<SampleDetailPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<SampleEvent> events = [];
  bool fromLocal = false;
  bool saving = false;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final result =
          await widget.repository.getEventsForSample(widget.sample.id);
      if (!mounted) return;
      final List<SampleEvent> sorted = sortByDate(result.events);
      setState(() {
        events = sorted;
        fromLocal = result.fromLocal;
        selectedType = nextEventType(currentStatus(sorted));
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se pudo cargar el historial';
        isLoading = false;
      });
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _register() async {
    final String? type = selectedType;
    if (type == null) return;

    setState(() {
      saving = true;
    });
    try {
      await widget.repository.registerEvent(widget.sample.id, type);
      if (!mounted) return;
      _showMessage('Evento registrado');
      await _load();
    } on InvalidTransitionException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        'No se pudo guardar en Firestore. El evento no fue registrado.',
      );
    }
    if (!mounted) return;
    setState(() {
      saving = false;
    });
  }

  String _two(int number) {
    return number.toString().padLeft(2, '0');
  }

  /// Fecha local con formato dd/MM/yyyy HH:mm, sin paquetes extra.
  String _formatDate(DateTime date) {
    final DateTime local = date.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sample.id)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading && events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final String? status = currentStatus(events);

    final List<Widget> children = [
      _SampleHeader(sample: widget.sample, status: status),
      const SizedBox(height: 12),
    ];

    if (fromLocal) {
      children.add(const LocalDataNotice());
      children.add(const SizedBox(height: 12));
    }

    children.add(const SizedBox(height: 12));
    children.add(
      Text(
        'Historial de procesamiento',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    children.add(const SizedBox(height: 14));

    if (events.isEmpty) {
      children.add(const _EmptyHistory());
    } else {
      for (int i = 0; i < events.length; i++) {
        children.add(
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(statusLabel(events[i].type)),
              subtitle: Text(_formatDate(events[i].createdAt)),
            ),
          ),
        );
      }
    }

    children.add(const SizedBox(height: 18));
    children.add(_buildRegisterZone(nextEventType(status)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget _buildRegisterZone(String? next) {
    if (next == null) {
      return const Text('Procesamiento finalizado: la muestra está archivada.');
    }

    final List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < eventFlow.length; i++) {
      items.add(
        DropdownMenuItem<String>(
          value: eventFlow[i],
          child: Text(statusLabel(eventFlow[i])),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedType,
            items: items,
            onChanged: saving
                ? null
                : (String? value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: saving ? null : _register,
          child: const Text('Registrar evento'),
        ),
      ],
    );
  }
}

class _SampleHeader extends StatelessWidget {
  const _SampleHeader({required this.sample, required this.status});

  final Sample sample;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final int percent = progressPercent(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.science_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sample.id,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Chip(label: Text(statusLabel(status))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: percent / 100),
                ),
                const SizedBox(width: 10),
                Text('$percent%'),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _InfoField(label: 'Tipo', value: sample.type),
                _InfoField(label: 'Origen', value: sample.origin),
                _InfoField(label: 'Prioridad', value: sample.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Esta muestra aun no tiene eventos de procesamiento.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
