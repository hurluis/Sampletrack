# SampleTrack

Examen Práctico 2 de Desarrollo de Aplicaciones Móviles. Variante **G** (trío).

El catálogo de muestras es local (`lib/data/sample_seed.dart`). Cloud Firestore
(`sample_events`) y Drift solo guardan los **eventos**; el estado actual de cada
muestra se calcula con el evento más reciente de su `sampleId`.

## Flujo

- **Lectura:** Firestore primero → se actualiza la caché de Drift. Si Firestore
  falla, se muestran los últimos eventos de Drift y la pantalla lo avisa.
- **Registro:** se valida la transición (sin saltar estados) → se guarda en
  Firestore → solo entonces en Drift. Si Firestore falla se informa el error y
  el evento no queda confirmado.
- **Estados:** RECEIVED → PREPARED → IN_ANALYSIS → VALIDATED → ARCHIVED.

## Variante G

- Porcentaje de progreso por muestra (20 / 40 / 60 / 80 / 100 %).
- Resumen por estado en la pantalla principal.
- Sección **Pendientes de validación**: muestras en IN_ANALYSIS ordenadas por
  prioridad (Urgente, Alta, Normal).

## Cómo correrlo (mismos pasos de la guía de clase)

```bash
flutter create . --platforms=windows
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

- `flutter create .` solo agrega las carpetas de plataforma que faltan (el repo
  no las trae); revisa `git status` para confirmar que no cambió nada en `lib/`.
- `build_runner` genera `lib/database/app_database.g.dart`. Después de
  generarlo, hacerle commit.
- `lib/firebase_options.dart` (FlutterFire) ya apunta a `veterinaria-mobile-dev`
  con configuración para **windows** y **web**. Para el Android Emulator hay que
  agregarlo:
  `dart pub global run flutterfire_cli:flutterfire configure --project=veterinaria-mobile-dev --platforms=android`
- Firestore debe estar creado en ese proyecto, en Test mode. La colección
  `sample_events` la crea la primera escritura.
- No ejecutar en Chrome: Drift usa `dart:io`, igual que en clase.

## Pruebas

```bash
flutter test
```

`test/sample_status_test.dart` cubre estados, transiciones y la variante G (no
necesita Firebase).
