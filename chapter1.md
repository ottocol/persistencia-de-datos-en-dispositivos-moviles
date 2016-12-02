# Persistencia básica en iOS

Aquí veremos APIs básicos para almacenar datos

## Archivos y directorios en iOS

En iOS el sistema de archivos al completo no es visible para una aplicación cualquiera ya que por motivos de seguridad está contenida en lo que se denomina un *sandbox*. Una aplicación solo puede acceder a los archivos y directorios dentro de su *sandbox*, y a la inversa otras aplicaciones no pueden acceder a ellos.

El *sandbox* tiene una estructura de directorios estandarizada, donde cada directorio tiene un papel específico reservado en la aplicación. Nuestra aplicación puede crear y modificar libremente archivos y directorios, aunque siempre debería respetar el papel que el sistema le asigna a cada directorio.

Primero veremos cuál es la estructura “estándar” del *sandbox* y luego el API para abrir, crear y modificar archivos y directorios.

### El sistema de archivos de cada aplicación

Cuando se instala una aplicación en un dispositivo iOS el sistema crea una estructura de directorios como la que aparece en la siguiente figura.

![](img/ios%20filesystem.png)

Los directorios más importantes son los siguientes:

- *nombre_de_la_aplicacion*`.app/`: aunque por la extensión podría parecer que es un archivo se trata de un directorio, que contiene lo que se denomina el *bundle* de la aplicación: el ejecutable, los iconos, imágenes, sonidos, etc.
- `Documents/`: es el directorio reservado para el contenido creado por el usuario. Si por ejemplo nuestra aplicación es un editor de textos, aquí es donde deberíamos almacenarlos.
- `Library/`: no suele contener directamente archivos sino solamente dos subdirectorios:
    - `Caches/`: donde almacenamos los datos que se pueden volver a recrear sin problemas si es necesario. Por ejemplo índices de datos de nuestra aplicación que sirvan para hacer las búsquedas más rápidas. Por ello iOS no hace copia de seguridad de este directorio cuando hacemos un *backup* del dispositivo.
    - `Preferences/`: las preferencias de configuración de la aplicación, que posteriormente veremos con más detalle.
    - `Application Support/`: contenido generado por la aplicación pero que no ha sido creado directamente por el usuario.
- `tmp/`: como es lógico está reservado a archivos y directorios temporales, de los que iOS tampoco hará copia de seguridad.


     


### Localizar los directorios del *sandbox*

Antes de poder realizar cualquier operación sobre un archivo o directorio, tenemos primero que *localizarlo* en el sistema de archivos, es decir, encontrar su *path* absoluto - desde la raíz del sistema de archivos. Aunque en iOS no podemos “salirnos fuera” del *sandbox* este paso sigue siendo necesario. 

En iOS podemos dar cualquier trayectoria de un archivo de dos formas distintas: como *path* local (un `NSString`) o  como URLs, que uniformizan el tratamiento de las rutas y nos permite también especificar la localización de recursos remotos. En el API las URLs se representan mediante un tipo especial, `NSURL`. Los nombres de los métodos que trabajan con *paths* generalmente acaban en `Path` y ocurre lo propio con los que trabajan con URLs (que, lógicamente, acaban en `URL`).

En la documentación oficial de iOS Apple recomienda usar URLs en lugar de *paths*.

#### El directorio principal de la aplicación

Acceder al directorio con el *bundle* de la aplicación (el `.app`) es sencillo:

    NSString *bundleDir = [[NSBundle mainBundle] bundlePath];

Ya hemos visto antes este tipo de código cuando accedíamos a imágenes y otros archivos distribuidos con la aplicación.

Con el método `bundleURL ` podemos obtener también el *path* en forma de URL (en el API un objeto `NSURL`).

#### Los directorios “típicos”

Para obtener la URL de un directorio del *sandbox* se usa el método `URLsForDirectory:inDomains`, de la clase `FileManager`, que es la que nos sirve para gestionar archivos y directorios. Al método le pasamos un par de constantes:
- El tipo de directorio que estamos buscando (por ejemplo para `Library/` el valor es `NSLibraryDirectory`, para `Documents` es `NSDocumentDirectory` y para `Cache`, `NSCachesDirectory`). Se puede consultar la [referencia completa](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/c_ref/NSSearchPathDirectory), aunque la mayoría de valores solo tienen sentido en OSX.
- El “dominio” o ámbito de la búsqueda. Siempre usaremos el valor `NSUserDomainMask`, que en OSX indica el directorio del usuario, pero en iOS en realidad se refiere al ámbito de la aplicación actual. 

Por ejemplo, así obtendríamos la URL del directorio `Documents` de la aplicación actual:


    //El NSFileManager es la clase básica 
    //para interactuar con el sistema de ficheros
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager 
       URLsForDirectory:NSDocumentDirectory
       inDomains:NSUserDomainMask];
    //Nótese que se obtiene un array de URLs, no una sola
    if ([urls count] > 0){
       //Como en una app iOS solo hay un directorio 'Documents'
       //será la primera posición del array
       NSURL *docsFolder = urls[0];
       NSLog(@"%@", docsFolder);
    } else {
       NSLog(@"Error al buscar el directorio 'Documents'");
    }


Si ejecutamos el código anterior en un dispositivo real nos aparecerá una URL del estilo `file:///var/mobile/Containers/Data/Application/id_de_la_aplicacion/Documents`.

En el simulador la URL será similar pero la primera parte de la trayectoria cambia ya que se refiere a donde se está ejecutando la app dentro del simulador, algo como `file:///Users/[nombre_usuario]/Library/Developer/CoreSimulator/Devices/[id_del_dispositivo]/data/Containers/Data/Application/[id_de_la_aplicacion]/Documents/`. Para complicar un poco más el asunto, el identificador de la app cambiará cada vez que pongamos en marcha el simulador.

#### El directorio temporal

Podemos obtener el *path* del directorio para archivos temporales con la función `NSTemporaryDirectory`. Nótese que es una función y no un método (como por ejemplo `NSLog`) .

    NSString *tmpDir = NSTemporaryDirectory();
    NSLog(@"Dir. archivos temporales: %@", tmpDir);

> Durante el desarrollo en el simulador puede ser necesario localizar físicamente los directorios de la aplicación en el disco para poder verificar las operaciones sobre archivos y directorios. Para ayudarnos en esta tarea podemos usar alguna utilidad de terceros como la aplicación [Simpholders 2](http://simpholders.com)

### Listar el contenido de los directorios

Sabiendo la URL de un determinado directorio podemos listar sus contenidos con el método `contentsOfDirectoryAtURL:includingPropertiesForKeys:options:error`

    NSString *miBundleURL = [[NSBundle mainBundle] bundleURL];
    NSError *error = nil;
    NSArray *contenidos = [fileManager
                           contentsOfDirectoryAtURL: miBundleURL
                           includingPropertiesForKeys: @[
                            NSURLCreationDateKey,
                            NSURLIsDirectoryKey
                       ];
                           options: 0
                           error:&error];

- El parámetro `includingPropertiesForKeys` es un array de constantes en el que especificamos la información que queremos obtener de cada uno de los items
- options puede ser 0 o bien `NSDirectoryEnumerationSkipsHiddenFiles`para indicar que no queremos obtener los archivos o directorios ocultos.

Para una URL que representa uno de los items listados podemos obtener una propiedad con el método `getResourceValue:forKey:error`. Continuando con el ejemplo anterior, para listar la fecha de creación de cada item, haríamos algo como:

    for (NSURL *url in contenidos) {
       NSDate *fecha;
       NSError *error;
       [url getResourceValue:&fecha 
            forKey:NSURLCreationDateKey 
            error:&error];
       NSLog(@"%@ creado el %@",url.lastPathComponent, fecha);
    }

Una versión simplificada del listado de directorios nos la da el método `contentsOfDirectoryAtPath:error` que trabaja a partir de un *path* en forma de `NSString` y como se ve no permite obtener propiedades de los items listados, solo nos devuelve un `NSArray` de `NSString` con los nombres.

### Property lists

Hay una serie de clases de Cocoa que son fácilmente serializables en un archivo. Tenemos métodos para leer una instancia desde un archivo y también para almacenarla. Estas clases son `NSString`, `NSData`, `NSNumber`, `NSDate`, y las colecciones `NSArray` y `NSDictionary` (incluyendo las versiones mutables de todas, es decir `NSMutableString`, `NSMutableArray` y `NSMutableDictionary`).

Eso sí, solo podemos guardar colecciones de objetos que a su vez sean serializables. Es decir, vamos a poder guardar de forma sencilla un `NSArray` de `NSDate` pero no uno que contenga una clase propia o uno que contenga una clase genérica de Cocoa.

Las estructuras de datos que podemos montar con las clases anteriores son lo que se conoce como *property lists*, y aunque su uso no está recomendado para guardar gran cantidad de información, ni pueden almacenar objetos de una clase arbitraria, son sencillas de manejar y lo bastante flexibles para cubrir un conjunto amplio de casos de uso (por ejemplo, guardar el estado actual en un juego, o el historial de últimas operaciones hechas con una calculadora).

### Guardar una property list

Para guardar una *property list* en un archivo, primero creamos la estructura de datos que deseamos almacenar.


    NSArray *miArray = @[@1,@2,@3];
    NSDictionary *dict =  @{
         @"un_valor" : @"hola",
         @"otro_valor" : miArray
    };


Hemos creado esta estructura simplemente para que se vea que puede haber colecciones dentro de colecciones.

> Para poder almacenarse en una *property list* los diccionarios tienen que usar claves que sean `NSString`, no pueden usar de otro tipo
 
Para almacenar la estructura en un archivo podemos usar la familia de métodos `writeToFile` que implementan las clases `NSString`, `NSData`, `NSArray` y `NSDictionary`. Guardaremos la “raíz” de la estructura, en nuestro caso el `NSDictionary *dict`:

    //Buscamos la URL de la carpeta de Documents
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory
                                 inDomains:NSUserDomainMask];
    //Suponemos de modo temerario que lo anterior no ha fallado
    NSURL *docs_url = urls[0];
    NSURL *fich = [docs_url URLByAppendingPathComponent:@"mi_plist.plist"];
    if ([dict writeToURL:fich atomically:YES])
        NSLog(@"\nSe ha escrito el archivo correctamente");
    else
        NSLog(@"\nError al guardar %@", fichPlist.absoluteString);

Si estamos en el simulador podemos ir al directorio correspondiente a `Documents` y abrir el archivo `mi_plist.plist` con un editor de texto (o con el propio Xcode). Veremos el siguiente contenido:


    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>otro_valor</key>
        <array>
            <integer>1</integer>
            <integer>2</integer>
            <integer>3</integer>
        </array>
        <key>un_valor</key>
        <string>hola</string>
    </dict>
    </plist>


Como vemos las *property lists* se serializan por defecto en formato XML, lo que  las hace fácilmente editables. De hecho Xcode tiene un editor de este formato.

### Leer una property list de un fichero

Cuando tenemos el *path* del fichero y conocemos el tipo de datos de la “raíz” de la *property list*  (un `NSDictionary` o un `NSArray`) podemos leer los datos con el método `initWithContentsOfFile`, de `NSDictionary` o `NSArray`, respectivamente. Por ejemplo


    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path_plist];


Si en lugar de con *paths* estamos trabajando con URLs el método correspondiente sería `initWithContentsOfURL`.

Usando Xcode es sencillo añadir un fichero `.plist` al proyecto. Para crear uno de estos ficheros, en `File>New>File...` elegir el tipo `Resource` y entre de los documentos de este tipo seleccionar “property list”. Como ya hemos comentado, Xcode tiene un editor de ficheros `.plist` bastante amigable.

Al añadir el fichero de este modo, quedará incluido en el *bundle* de la aplicación. Obtener el *path* conociendo el nombre y la extensión es muy sencillo:


    //obtiene el path del fichero "prueba.plist" del bundle
    NSString *path_plist = [[NSBundle mainBundle]
                            pathForResource:@"prueba"
                            ofType:@"plist"];



> El *bundle* de la aplicación es solo de lectura, por lo que un .plist almacenado en esta localización no será modificable. La estrategia habitual para solucionarlo es hacer que cuando arranque la aplicación se realice una copia en otro directorio con permisos de escritura, típicamente `Documents` y que a partir de entonces se trabaje con esa copia.

Si preferimos trabajar con URLs el método correspondiente es `URLForResource:withExtension`.

## Preferencias de usuario

En la mayoría de las aplicaciones podemos configurar una serie de parámetros que permiten adaptar su comportamiento a las preferencias o necesidades del usuario. Son elementos tales como colores, tipos de fuentes, unidades de medida, nombres de usuarios y contraseñas de servicios de terceros, etc.

iOS nos ofrece un mecanismo estándar para almacenar estas preferencias de modo permanente. El API es bastante sencillo y nos permite establecer unos valores por defecto, modificarlos según lo que diga el usuario y leer los valores previamente fijados. 

Hay que destacar que iOS solo nos da el API para leer/almacenar las preferencias, pero no el interfaz de usuario para mostrarlas/modificarlas, que es nuestra responsabilidad. Hay una excepción: si queremos que nuestras preferencias aparezcan dentro de las del sistema, el propio iOS se encargará de la interfaz.

### Qué se puede guardar en las preferencias

Desde el punto de vista del tipo de datos, las preferencias de usuario no son más que una *property list* en la que el objeto “raíz” debe ser un `NSDictionary`.

> El fichero .plist donde se serializan las preferencias estará almacenado en el directorio `Library/Preferences` de la aplicación. Su nombre será el del proyecto de Xcode, precedido del “organization identifier” del proyecto. Por defecto se genera en formato binario.  Aunque no esté en modo XML podemos igualmente abrirlo y editarlo con el editor de .plist de Xcode. También podemos convertirlo a XML con una herramienta en línea de comandos llamada `plutil`, instalada por defecto en el sistema:

    plutil -convert xml1 -o resultado_xml.plist fichero_original.plist

A primera vista parece que solo poder usar objetos de *preference lists* pueda limitar bastante el ámbito de aplicación, pero hay que tener en cuenta que con un poco de ingenio probablemente no sea muy difícil transformar los datos de una clase cualquiera a un array o diccionario de cadenas, fechas y números. Y en el peor de los casos siempre podemos convertir cualquier clase propia a `NSData` mediante un proceso llamado `archiving` o `coding` (lo que en otros lenguajes como por ejemplo Java se suele denominar *serialización*). Veremos este proceso en sesiones posteriores.

### Acceder a las preferencias

Las preferencias del usuario actual son accesibles a través del *singleton* de la clase `NSUserDefaults`. Para acceder a la única instancia, usar el método de clase `standardDefaults`

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

> Como las aplicaciones iOS están en un *sandbox* cada una solo tiene acceso a sus propias preferencias. El propio sistema no puede cambiar las preferencas de nuestra aplicación, salvo las que coloquemos dentro de las “generales”, como veremos en el punto siguiente

Dentro del almacén de preferencias cada una de ellas tiene una clave, que será una cadena, y un valor. Así, podemos acceder a una preferencia con una familia de métodos al estilo del `objectForKey` usado en diccionarios. Tenemos un método por cada uno de los tipos de datos que podemos tener almacenado: `integerForKey:`, `boolForKey:`, `floatForKey:`, `doubleForKey:`, `arrayForKey:`, `objectForKey:`,…

Por ejemplo:


    NSString *nick = [prefs stringForKey:@"nick"];
    NSInteger creditos = [prefs integerForKey:@"creditos"];


Hay un pequeño problema con el código anterior: si no se hubiera guardado una preferencia con la clave `creditos` el valor obtenido sería 0. Pero ¿cómo diferenciar si la preferencia se ha fijado a 0 o bien no se ha fijado?. La solución más adecuada pasa por registrar *valores por defecto* para todas las preferencias, de modo que no pueda haber una preferencia con un valor no fijado, bien sea porque se ha hecho por defecto o bien sea porque lo ha hecho el usuario.

  
### Registrar valores por defecto

Podemos registrar un conjunto de preferencias por defecto pasándole un diccionario al método `registerDefaults` de `NSUserDefaults`:


    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs registerDefaults:@{
              @"nick": @"(anonimo)",
              @"creditos" : @100
     }];


Hay que destacar que *los valores registrados por defecto no son permanentes*. Es decir, que hay que registrarlos cada vez que arranque la aplicación.

Si registramos un valor por defecto y este ya ha sido fijado por el usuario el valor por defecto no “machacará” al ya fijado. Cuando iOS busca el valor para una preferencia sigue un esquema de “dominios”, en el que si no encuentra la clave en un dominio la busca en el siguiente. De este modo, primero busca en el dominio de los valores fijados por el usuario y si lo encuentra aquí lo devuelve. Es solo si no lo encuentra aquí cuando pasa a consultar los valores por defecto.

En un poco tedioso tener que volcar en el código un `NSDictionary` con todos los valores por defecto. Un método muy habitual de registrar los valores por defecto de modo más “limpio” es almacenarlos en un archivo `.plist` y deserializarlos con `initWithContentsOfFile`, como vimos en el apartado de cómo leer *property lists*.

### Modificar las preferencias

Simplemente tenemos que fijar la clave al valor que queramos usando la familia de métodos `setXXX:forKey:`


    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"Pepito" forKey:@"nick"];
    [prefs setInteger:50 forKey:@"creditos"];


Por cuestiones de eficiencia, iOS no hace persistente el cambio inmediatamente sino a intervalos regulares o en momentos especiales (por ejemplo justo antes de salir de la aplicación). Una *property list* no se puede modificar de manera parcial y hay que crearla entera de nuevo, de manera que no sería eficiente persistir siempre los datos tras ejecutar el `setXXX:forKey:`. 

Una forma de “forzar” la persistencia si estamos probando la aplicación es salir de ella pulsando en el botón “home” (`Shift+Cmd+H` en el simulador) para que pase a *background*, momento en el que, como ya hemos dicho, iOS almacena de modo permanente los valores actuales. 

> Como iOS tiene que modificar los datos si hay preferencias modificadas desde la última vez que se guardaron, no es aconsejable cambiar el valor de una preferencia “a las primeras de cambio”. Solo es adecuado si no es previsible que vaya a cambiar dentro de poco tiempo. Una estrategia típica es fijar los valores justo antes de salir de la aplicación.

### Ubicar las preferencias en el “panel de control” general

El sistema nos da la posibilidad de controlar ciertas preferencias de nuestra aplicación dentro de las preferencias generales del sistema, en un apartado reservado a ella. Esto es lo que se conoce en iOS como un *settings bundle*. Podemos colocar aquí todas las preferencias o solo algunas.

> Apple recomienda colocar en el sistema solo las preferencias que se cambien en raras ocasiones. Por ejemplo en una aplicación que gestione un servicio de terceros podemos colocar aquí las credenciales de uso del servicio (login y password)

A diferencia de las preferencias dentro de la aplicación, donde iOS nos da un API para editarlas/verlas pero no una interfaz, en este caso es al contrario. Editando un fichero `.plist` con un formato especial podemos crear de modo sencillo una interfaz para las preferencias. 

Para crear un *settings bundle* en Xcode ir a `File > New > File ...` y en el cuadro de diálogo que aparecerá, dentro del tipo `Resource` elegir  `Settings Bundle`. Se creará un archivo de tipo *property list* llamado `Root.plist` y algunos archivos auxiliares para la internacionalización (necesarios ya que vamos a tratar con elementos de interfaz).

Si editamos el `Root.plist` con el editor de Xcode podemos ver que tiene un formato un tanto especial: la lista de preferencias se representa con un array de items. Las propiedades de estos items son las que determinan el tipo de *widget* a usar para editar/ver la preferencia, sus parámetros y la clave con la que se va a almacenar la preferencia asociada. 

En el ejemplo que se muestra a continuación, que se corresponde con el `Root.plist` que crea por defecto Xcode, puede verse que el item 1 es de tipo “campo de texto”, que su `title` (la etiqueta que se ve en las preferencias) es `Name`, que el *widget* tiene una serie de propiedades (cuando se edita aparece un teclado alfabético,  no es seguro - o sea, se muestra el contenido, …) y está asociada a la preferencia cuya clave es `name_preference` (propiedad `Identifier`). 

No tenemos espacio en estos apuntes para explicar más detalladamente el proceso de configuración del *bundle*. El lector interesado puede consultar el apartado “[implementing an iOS settings bundle](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html)” de la “[Preferences and Settings Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UserDefaults/Introduction/Introduction.html#//apple_ref/doc/uid/10000059i-CH1-SW1)” de Apple.

![](img/root.plist.png "Contenido del archivo Root.plist")

![](img/settings.png "Cómo se muestran en el sistema las preferencias configuradas en el Root.plist")




