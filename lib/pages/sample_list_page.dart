import 'package:flutter/material.dart';

import '../data/sample_seed.dart';
import '../models/sample.dart';
import '../models/sample_event.dart';
import '../models/sample_status.dart';
import '../repositories/sample_event_repository.dart';
import '../widgets/local_data_notice.dart';
import '../widgets/sample_card.dart';
import 'sample_detail_page.dart';

class SampleListPage extends StatefulWidget {
  const SampleListPage({super.key, required this.repository});

  final SampleEventRepository repository;

  @override
  State<SampleListPage> createState() => _SampleListPageState();
}

class _SampleListPageState extends State<SampleListPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<SampleEvent> events = [];
  bool fromLocal = false;

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
      final result = await widget.repository.getAllEvents();
      if (!mounted) return;
      setState(() {
        events = result.events;
        fromLocal = result.fromLocal;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'No se pudieron cargar los eventos';
        isLoading = false;
      });
    }
  }

  Future<void> _openDetail(Sample sample) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SampleDetailPage(
          sample: sample,
          repository: widget.repository,
        ),
      ),
    );
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.biotech_outlined),
            SizedBox(width: 10),
            Text('SampleTrack'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
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

    final Map<String, String?> statuses = statusBySample(sampleSeed, events);
    final Map<String, int> summary = summaryByStatus(statuses);
    final List<Sample> pending = pendingValidation(sampleSeed, statuses);

    final List<Widget> children = [];

    if (fromLocal) {
      children.add(const LocalDataNotice());
      children.add(const SizedBox(height: 12));
    }

    // Resumen por estado
    final List<Widget> summaryChildren = [
      Text(
        'Resumen por estado',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: 8),
    ];
    for (String label in summary.keys) {
      summaryChildren.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${summary[label]}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }
    children.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: summaryChildren,
          ),
        ),
      ),
    );
    children.add(const SizedBox(height: 12));

    // Pendientes de validación (variante G)
    final List<Widget> pendingChildren = [
      Text(
        'Pendientes de validación',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: 8),
    ];
    for (int i = 0; i < pending.length; i++) {
      final Sample sample = pending[i];
      pendingChildren.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(sample.id),
          subtitle: Text(sample.type),
          trailing: Chip(label: Text(sample.priority)),
          onTap: () => _openDetail(sample),
        ),
      );
    }
    if (pending.isEmpty) {
      pendingChildren.add(const Text('No hay muestras en análisis.'));
    }
    children.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pendingChildren,
          ),
        ),
      ),
    );
    children.add(const SizedBox(height: 20));

    // Muestras
    children.add(
      Text(
        'Muestras',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    children.add(const SizedBox(height: 12));
    for (int i = 0; i < sampleSeed.length; i++) {
      final Sample sample = sampleSeed[i];
      children.add(
        SampleCard(
          sample: sample,
          status: statuses[sample.id],
          onTap: () => _openDetail(sample),
        ),
      );
      children.add(const SizedBox(height: 12));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}
