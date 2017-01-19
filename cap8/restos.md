## Apéndice: migraciones ligeras en iOS<10

Hay una serie de migraciones que Core Data puede hacer de forma más o menos automática. Por ejemplo al añadir un atributo se añadirá la nueva columna y simplemente los datos antiguos tendrán valor `nil` para la propiedad. O al cambiar una entidad de nombre se cambiará automáticamente el nombre de la tabla en la base de datos.


`The model used to open the store is incompatible with the one used to create the store.`

Este error es fácilmente subsanable yendo al directorio `Documents` de la aplicación y eliminando los ficheros del almacenamiento persistente (si es una BD SQLite, desde iOS7 hay 3 ficheros, un `.sqlite`, un `.sqlite-wal` y un `.sqlite-shm`). Si volvemos a arrancar la aplicación ya no habrá problema ya que no hay almacenamiento persistente y Core Data lo puede generar partiendo de cero. Pero evidentemente esto implica **perder todos los datos que teníamos guardados**. 

En desarrollo perder los datos no tiene la menor importancia si tenemos el típico código de prueba que podemos volver a ejecutar para rellenar la BD. Pero si ya hemos distribuido la aplicación en la App Store y sacamos una nueva versión con el modelo de datos modificado, en principio todos los usuarios tendrían que borrar todos los datos para que les funcionara la nueva versión (!). Evidentemente esto no tiene sentido, tiene que haber alguna forma de que el modelo de datos pueda ir cambiando y los datos se vayan traspasando de una versión a otra. Este “traspaso” de los datos es lo que se conoce como una **migración**.


## Versiones del modelo de datos


## Migraciones “ligeras”

Las buenas noticias son que si los cambios en el modelo de datos no son demasiados, el propio Core Data puede hacer una migración automática, o como la llama Apple, “ligera” (*lightweight migration*).

Este tipo de migración se corresponde con estas operaciones:

- Añadir o eliminar un atributo o relación
- Convertir en opcional un atributo requerido
- Convertir en requerido un atributo opcional, siempre que se dé un valor por defecto
- Añadir o eliminar una entidad
- Renombrar un atributo o relación
- Renombrar una entidad

Si hemos hecho alguno/s de los **cambios anteriores que no implican renombrado**, la migración ligera es especialmente sencilla. Lo único que tenemos que hacer es modificar el código de inicialización del `NSPersistentStoreCoordinator`. En el `addPersistentStoreWithType` , hay que pasar un par de opciones en el  parámetro `options` que indican que queremos una migración totalmente automática:

    NSDictionary *opts = @{
          NSMigratePersistentStoresAutomaticallyOption: @YES,
          NSInferMappingModelAutomaticallyOption: @YES
    };
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
    configuration:nil URL:storeURL 
    options:opts error:&error]

Ahora cuando ejecutemos la aplicación **se detectará que la versión actual del modelo de datos es posterior a la que se usó para generar la base de datos**. En consecuencia, tal y como acabamos de configurar en el código, los datos se migrarán automáticamente a la nueva versión de la BD.

Si renombramos algo el proceso es solo un poco más laborioso. Por ejemplo supongamos que en la aplicación de notas cambiamos el atributo `fecha`por `momento`. Habiendo cambiado el nombre, mantenemos seleccionado el atributo y en el panel de la derecha, tercer icono (Data Model Inspector), en el cuadro de texto llamado `Renaming ID` tecleamos el nombre antiguo. Con esto estamos especificando lo que en Core Data se llama un *mapping model*, es decir una asociación de elementos que permite pasar del modelo antiguo al nuevo.

![](renaming%20id.png)

> Por supuesto, todos los lugares del código donde antes se hiciera referencia al atributo `fecha` ahora habrá que cambiarlos para que reflejen el nuevo nombre. Core Data no va a ayudarnos en esto. 

## Migraciones “pesadas”

Puede haber cambios que no encajen en las operaciones previstas en las migraciones “ligeras”. Por ejemplo supongamos que queremos dividir un campo `apellidos` en `apellido1`y `apellido2` (o al contrario, partimos de dos y los queremos fusionar). En estos casos Core Data no puede inferir automáticamente la forma de transformar el modelo origen al modelo objetivo, y tenemos que especificar “manualmente” cómo hacer la transformación.

La transformación entre un modelo y otro se representa en iOS mediante un *mapping model*, y es lo que tenemos que proporcionarle a Core Data para que pueda actualizar los datos al nuevo modelo.

Lo que hará Core Data durante el proceso de migración es cargar cada entidad en memoria, convertirla del modelo actual al nuevo ayudándose del *mapping model* y guardarla de nuevo en el almacenamiento persistente. Y hemos dicho Core Data, pero en realidad lo que tendremos que hacer será escribir nosotros código que haga esta tarea. Además del trabajo para nosotros, las migraciones de este tipo son mucho más costosas en tiempo y capacidad de procesamiento que las ligeras. Normalmente la aplicación necesitará mostrar al usuario un cuadro de diálogo que le indique que se está realizando la operación.

Vamos a ver cómo se implementaría una migración “pesada” con un ejemplo concreto. Supongamos que en la aplicación de notas nos hemos dado cuenta de que el campo “categoria” no está del todo bien, ya que así solo podemos hacer que una nota pertenezca a una única categoría, y además cuando varias notas tienen la misma categoría cada una debe repetir el valor. Sería mejor tener una entidad “categoría” aparte y establecer una relación “uno a muchos” en ambas direcciones.

Lo primero es crear una nueva versión del modelo de datos con este cambio.

### Crear el “mapping model”

El nuevo modelo de datos tendrá el aspecto de la siguiente figura:

![](modelo_datos_v3.png)

ahora tenemos que crear el *mapping model* que nos transforme el modelo actual en el nuevo modelo. En `File > New` seleccionamos la categoría `Core Data` y elegimos la plantilla `Mapping Model`. El asistente nos preguntará cuál es el modelo origen, cuál el destino, y nos pedirá un nombre para el nuevo archivo `.xcmappingmodel` que creará.

Si abrimos el archivo creado, veremos que Xcode ha intentado deducir la correspondencia entre el modelo origen y el destino. 

![](mapping_model.png)

A la izquierda veremos los *Entity Mappings* (cómo pasar de una entidad antigua a una nueva). Típicamente a estos los llama con el nombre de la entidad antigua y la nueva, algo como `NotaToNota`. Para las entidades nuevas pone simplemente el nombre de la entidad. 

Para cada Entity Mapping tenemos los *Attribute Mappings* y los *Relationship mappings* correspondientes. Se usa un conjunto de variables predefinido para expresarlos. Por ejemplo, `$source` indica la entidad origen. De modo que si en un atributo vemos `$source.texto` indica que Xcode ha deducido que para generar este atributo tenemos que copiar el valor del atributo `texto` de la entidad original. Para una lista de variables se recomienda consultar la [sección correspondiente](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmMappingOverview.html#//apple_ref/doc/uid/TP40004399-CH5-SW1) de la “[Core Data Model Versioning and Data Migration Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/Introduction.html#//apple_ref/doc/uid/TP40004399-CH1-SW1)”.
 



### Crear la “migration policy”

De la migración entre entidades del modelo “antiguo” y del “nuevo” se encarga la clase `NSEntityMigrationPolicy`. Si queremos personalizar la migración, como es nuestro caso para generar la nueva entidad `Categoria` a partir de los valores del antiguo atributo `categoria`, tendremos que crear una clase propia que herede de ella:


![](create_migration_policy.png)


Tendremos también que especificar en el Mapping Model que vamos a usar esta clase para hacer una migración de entidad determinada. Seleccionamos la migración `NotaToNota` y en las propiedades escribimos el nombre de la nueva clase en el campo `Custom Policy`.

![](mapping_model_custom_policy.png)

En la clase hay una serie de métodos que podemos sobreescribir para adaptar la migración a nuestras necesidades, pero el único que suele ser necesario es `createDestinationInstancesForSourceInstance:entityMapping:manager:error:`, que se encargaría de crear a partir de una instancia de la antigua entidad, la nueva entidad (o nuevas, si debe haber más de una). Este método se irá llamando para cada una de las entidades actualmente en el almacén persistente, para irlas migrando una a una. 

Para nuestro problema particular, lo que debemos hacer en este método es obtener la categoría a la que pertenece la nota y crear una nueva entidad `Categoria` basada en ella. Después establecemos la relación entre la nota y su por ahora única categoría. Hay un pequeño problema a tener en cuenta: como habrá varias notas de la misma categoría no podemos crear directamente la entidad `Categoria`, solo la crearemos si no existe ya. Vamos a guardar las `Categoria` que creamos en un `NSMutableDictionary` para poder saber las que ya hemos creado. En nuestra clase definiríamos una variable `static`:

    static NSMutableDictionary *categorias;

y para inicializarla usaremos el método `initialize`, que se llama cuando se inicializa la clase propiamente dicha, antes de que exista todavía ninguna instancia de ella, momento apropiado para inicializar variables `static`:

    + (void)initialize {
        categorias = [[NSMutableDictionary alloc] init];
    }
 
Finalmente aquí tenemos el código que hace la migración en sí

    - (BOOL) createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error {
        
        //Crea una nueva nota en el "nuevo modelo" con las mismas propiedades que la nota actual
        NSManagedObject *notaDestino = [NSEntityDescription insertNewObjectForEntityForName:@"Nota" inManagedObjectContext:manager.destinationContext];
        [notaDestino setValue:[sInstance valueForKey:@"texto"] forKey:@"texto"];
        [notaDestino setValue:[sInstance valueForKey:@"momento"] forKey:@"momento"];
        
        //Miramos si ya hemos creado una entidad Categoria para la categoria de la nota
        NSString *nombreCategoria = [sInstance valueForKey:@"categoria"];
        NSManagedObject *categoria = [categorias objectForKey:nombreCategoria];
        
        //Si no la hemos encontrado, la creamos
        if (!categoria) {
            categoria = [NSEntityDescription insertNewObjectForEntityForName:@"Categoria" inManagedObjectContext:manager.destinationContext];
            [categoria setValue:nombreCategoria forKey:@"nombre"];
            [categorias setObject:categoria forKey:nombreCategoria];
        }
        
        //Asociamos la nota con su por ahora única categoría
        //Como es una relación 1->N es un NSSet que por ahora tendrá un único elemento
        NSSet *categoriasDeNota = [[NSSet alloc]initWithObjects:categoria, nil];
        [notaDestino setValue:categoriasDeNota forKey:@"categorias"];
        
        
        //Al final siempre hay que llamar a este método para establecer correspondencia
        //entre entidad en el modelo actual y entidad en el nuevo
        [manager associateSourceInstance:sInstance withDestinationInstance:notaDestino forEntityMapping:mapping];
        
        
        return YES;
        
    }
    

Lo único que nos falta es configurar el *persistent store coordinator* para especificar que necesitamos una migración “pesada”. Al igual que en el caso de las migraciones “ligeras”, esto se hace con un diccionario de opciones. La diferencia es que en este caso indicamos que no se intente inferir automáticamente el “mapping model”

    NSDictionary *opts = @{
          NSMigratePersistentStoresAutomaticallyOption: @YES,
          NSInferMappingModelAutomaticallyOption: @NO
    };

Y ya está. Solo nos falta en el editor del modelo de datos *establecer como versión actual del modelo de datos la nueva versión*

![](set_current_model_version.png)

Cuando arranque la aplicación iOS detectará que el modelo de datos actual es incompatible con el almacén persistente y verá que en las opciones se especifica que no se debe inferir automáticamente el “mapping model”. Por tanto buscará un “mapping model” compatible con la versión origen y destino del modelo de datos y lo aplicará.
