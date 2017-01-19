## Apéndice: migraciones en versiones de iOS<10


Como vimos en la primera sesión de Core Data, el *stack* se gestiona con la clase `NSPersistentContainer`. Esta clase tiene activadas por defecto las migraciones automáticas, y por eso en iOS10 podemos hacer modificaciones al modelo de datos sin causar errores en tiempo de ejecución. No obstante esta clase es nueva de la versión 10. ¿Qué ocurre si necesitamos generar código compatible con versiones anteriores, o tenemos un proyecto "heredado" de esas versiones?.

Las clases que gestionan el *stack* de Core Data en iOS9 y versiones anteriores no tienen activadas las migraciones por defecto, y si en el proceso de desarrollo modificamos el modelo de datos nos encontraremos con que al ejecutar la aplicación se genera un mensaje de error:

```bash
The model used to open the store is incompatible with the one used to create the store
```

Para activar las migraciones automáticas en iOS<=9 tenemos que pasarle un parámetro adicional al *persistent store coordinator* cuando vamos añadiendo almacenamientos persistentes. Las opciones que indican si hay que intentar la migración automática van asociadas a la configuración del almacenamiento persistente. En concreto, en la plantilla que generan las versiones de Xcode anteriores a la 8 hay que hacer el siguiente cambio:

```swift
//ESTO SE AÑADE
let opciones = [
      NSInferMappingModelAutomaticallyOption : true,
      NSMigratePersistentStoresAutomaticallyOption : true
]
//ESTO YA ESTABA, pero antes con el options a nil
do {
    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: opciones)
} catch {
```

- `NSInferMappingModelAutomaticallyOption` indica que Core Data intente inferir el *mapping model* automáticamente. Esto es necesario para las migraciones ligeras, pero para las "pesadas" habrá que ponerlo a `false`, para que tome el modelo que nosotros le damos.
- `NSMigratePersistentStoresAutomaticallyOption` indica que se debe intentar hacer la migración. Cuando este valor está a `false` es cuando al detectar un cambio en el modelo de datos se genera un error en tiempo de ejecución.