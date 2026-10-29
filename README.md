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

## Cómo correrlo

El código de Drift se genera (no se escribe a mano). En el PC con Flutter:

```bash
flutter create . --platforms=windows,web
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

- `flutter create .` solo agrega las carpetas de plataforma que faltan; revisa
  `git status` para confirmar que no cambió nada en `lib/`.
- Después de generar, **versionar** `lib/database/app_database.g.dart`.
- `lib/firebase_options.dart` solo trae **web** y **windows**. Para Android hay
  que volver a correr `flutterfire configure`.
- Firestore debe existir en el proyecto `veterinaria-mobile-dev` y permitir
  lectura y escritura (modo de prueba). La colección `sample_events` se crea
  con la primera escritura.
- En **web**, Drift necesita `web/sqlite3.wasm` y `web/drift_worker.js`
  (copiarlos de la carpeta `web/` del proyecto de Veterinaria).

## Pruebas

```bash
flutter test
```

`test/sample_status_test.dart` cubre la lógica de estados, transiciones y la
variante G (no necesita Firebase).
