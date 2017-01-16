## Migraciones “pesadas”

Hay muchos cambios que no encajan en las operaciones previstas en las migraciones “ligeras”. Por ejemplo supongamos que tenemos el nombre y apellidos en un campo `nombre_completo` en el típico formato de *apellido_1 apellido_2, nombre* y queremos dividirlo en dos campos: `apellidos`  y `nombre` (o al contrario, partimos de dos y los queremos fusionar). En estos casos Core Data no puede inferir automáticamente la forma de transformar el modelo origen al modelo objetivo, y tenemos que especificar “manualmente” cómo hacer la transformación.

Como hemos dicho, la transformación entre un modelo y otro se representa en iOS mediante un *mapping model*, y es lo que tenemos que darle a Core Data para que pueda actualizar los datos al nuevo modelo.

Lo que hará Core Data durante el proceso de migración es cargar cada entidad en memoria, convertirla del modelo actual al nuevo ayudándose del *mapping model* y guardarla de nuevo en el almacenamiento persistente. Y hemos dicho Core Data, pero en realidad lo que tendremos que hacer será escribir nosotros código que haga esta tarea. Además del trabajo para nosotros, las migraciones de este tipo son mucho más costosas en tiempo y capacidad de procesamiento que las ligeras. Normalmente la aplicación necesitará mostrar al usuario un cuadro de diálogo o similar que le indique que se está realizando la operación.

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
