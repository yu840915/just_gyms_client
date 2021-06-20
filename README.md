## Library Overview

[json_serializable](https://pub.dev/packages/json_serializable) for JSON parser generation.
[flutter_gen_runner](https://pub.dev/packages/flutter_gen_runner) for resouce accessing code generation.
[hive](https://pub.dev/packages/hive) for local persistent storage.
[geojson](https://pub.dev/packages/geojson) for GeoJSON parsing, which sticks to older version of Firebase.

## Getting Started

After modifying JSON models, hive models, or adding new assets, you have to update generated code accordingly, run

```
flutter packages pub run build_runner build
```

or, if conflicts occurs, run

```
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Make sure `{proj}/.dart_tool/flutter_gen/pubjpec.yaml` is created before generation.
