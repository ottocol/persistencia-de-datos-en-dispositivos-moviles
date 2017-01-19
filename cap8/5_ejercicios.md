# Ejercicio de migraciones de datos

Vamos a hacer un par de modificaciones sobre el modelo de datos de (¡cómo no!) la aplicación de notas

> Antes de ponerte a hacer las modificaciones de esta sesión asegúrate de que has hecho un `commit` con el mensaje `terminada sesión 7`. También puedes hacer un `.zip` con el proyecto, llamarlo `notas_sesion_7.zip` y adjuntarlo en las entregas de la asignatura. Así cuando se evalúe el ejercicio el profesor podrá consultar el estado que tenía la aplicación antes de estos ejercicios.


## Migraciones “ligeras” (0,4)

- Ve al modelo de datos y crea una nueva versión con `Editor > Add model version...`
- Edita esta nueva versión y en ella cambia de nombre el campo “texto” por “contenido”. 
- Tendrás que indicar que esto es un cambio de nombre y no un campo nuevo. Selecciona el atributo y en sus propiedades pon como `renaming ID` el nombre antiguo(el campo está al final del todo del panel, quizá tengas que hacer *scroll* para verlo).

![](img/renaming_id_blanco.png)

- Tendrás que modificar el código fuente  
    - Puedes editar manualmente el archivo `Nota+CoreDataProperties.swift` y cambiar la propiedad antigua por la nueva, o bien volver a generar la clase `Nota` (eliminar la anterior y estando en el editor del modelo de datos,  `Editor > Add NSManagedObject subclass...`) 
    - En el resto de archivos fuente, donde salga alguna referencia a la propiedad `texto`, tendrás que cambiarla por `contenido`
- Fija la nueva versión del modelo como la versión actual (primero de los iconos del panel de la derecha, campo `Current` en `Model Version`)

![](img/version_actual.png)

Ejecuta la aplicación y comprueba que todo sigue funcionando. Si accedes a la carpeta con la base de datos podrás comprobar que en la tabla `ZNOTA` se ha cambiado la columna `texto` por `contenido`

## Migraciones “pesadas” (0,6)

Vamos a crear un nuevo campo llamado “titulo” para cada nota. Para las notas que ya existen, el título serán los primeros 10 caracteres del contenido. 

Lo implementaremos como una migración "pesada":

- Crea una nueva versión del modelo, llámala "MigracionPesada"
- Añádele a esta nueva versión el campo "titulo" de tipo "String"
- Crea un nuevo `mapping model` para decir cómo transformar los datos de la versión actual a la nueva: `File > New > File...` y en las plantillas de Core Data, elegir `Mapping Model`
- En el asistente de creación del *mapping model*,  indica que el "source" es la versión actual del modelo y el "target" es la nueva.
- Una vez creado el *mapping model* y antes de editarlo, crea la clase que implementa la migración (la *migration policy*): `File > New > File...` y en la plantilla de `Cocoa Touch Class` creamos una clase `MigracionPesada` que herede de `NSEntityMigrationPolicy`.
- Copia en esa clase este esqueleto de método. FALTA solo una línea que debes rellenar 

```swift
override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    //sacamos el contenido de la nota actual
    let notaOrigen = sInstance as! Nota
    let cad = notaOrigen.contenido

    //sacar una subcadena es rarito porque no se trabaja con pos. numéricas
    //sino con la clase Index
    let index = cad.index(cad.startIndex, offsetBy: 10)
    let tit = cad.substring(to: index)
    
    //creamos una nota de la nueva versión, no podemos usar la 
    //clase Nota, esa es la antigua
    let notaDestino = NSEntityDescription.insertNewObject(forEntityName: "Nota", into: manager.destinationContext)
    //FALTA: 
    // - usando setValue, fijar la propiedad "titulo" de "notaDestino" a "tit"

    //decimos que la nueva versión de "notaOrigen" es "notaDestino" 
    manager.associate(sourceInstance: notaOrigen, withDestinationInstance: notaDestino, for: mapping)
}
```

- Ahora editamos el *mapping model* y en el *entity mapping* llamado `NotaToNota`, ponemos como *custom policy* la clase `MigracionPesada`

- Modifica el `AppDelegate` para indicarle a Xcode que no queremos que se "invente" el *mapping model* sino que use el nuestro:

```swift
//CUIDADO: el name cambia, según el nombre del proyecto
//Esta línea queda tal cual esté, las modificaciones vienen a partir de ella
let container = NSPersistentContainer(name: "NotasCoreData")

//COMIENZAN MODIFICACIONES A INSERTAR
let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//CUIDADO: el nombre de la BD cambia, según el nombre del proyecto
let urlBD = urls[0].appendingPathComponent("NotasCoreData.sqlite")
let psd = NSPersistentStoreDescription(url: urlBD)
//que no se intente automatizar la migración
psd.shouldInferMappingModelAutomatically = false
psd.type = NSSQLiteStoreType

container.persistentStoreDescriptions = [psd]
```

- Modifica el listado de notas (el que usaba el *fetched results controller*) para que en vez de mostrar el campo `texto` se muestre el campo `titulo`
- Ya solo queda en el editor del modelo fijar la nueva versión como la actual y volver a ejecutar la aplicación
