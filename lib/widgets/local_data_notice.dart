import 'package:flutter/material.dart';

/// Aviso que se muestra cuando Firestore falló y los datos vienen de Drift.
class LocalDataNotice extends StatelessWidget {
  const LocalDataNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin conexión con Firestore: se muestran los últimos datos '
              'guardados en el dispositivo.',
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
