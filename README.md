# SampleTrack

Aplicación Flutter para consultar muestras de laboratorio y registrar los eventos de su procesamiento.

- Catálogo de muestras local.
- Eventos en Cloud Firestore (`sample_events`) con caché local en Drift.
- Estado actual e historial calculados a partir de los eventos.
- Variante G: progreso por estado, resumen por estado y pendientes de validación.

## Ejecución

```bash
flutter pub get
flutter run
```
