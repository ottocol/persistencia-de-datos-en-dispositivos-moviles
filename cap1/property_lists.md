## Property lists

Las *property list* son estructuras de datos tipo pares de clave-valor fácilmente serializables en iOS. Es decir, es sencillo escribir código para guardarlas en un archivo y recuperarlas posteriormente. En estas estructuras no se admite cualquier tipo de datos, solo determinadas clases. Estas son `NSString`, `NSData`, `NSNumber`, `NSDate`, y las colecciones `NSArray` y `NSDictionary`

> Todas estas clases son propias de un *framework* de Apple denominado *Foundation*. Este *framework* define clases básicas como cadenas, fechas, URLs,... que no existen directamente en Objective-C. Por eso son clases muy usadas al programar en este lenguaje. Sin embargo sí hay equivalentes en la librería estándar de Swift, y por eso hasta ahora no los hemos usado demasiado en nuestros programas. 

Eso sí, solo podemos guardar colecciones de objetos que a su vez sean serializables. Es decir, vamos a poder guardar de forma sencilla un `NSArray` de `NSDate` pero no uno que contenga una clase definida por nosotros o una clase cualquiera del sistema. Otra restricción es que las claves de los diccionarios deben ser de tipo cadena.

Las *property list* tienen dos limitaciones prácticas fundamentales:

- Como hemos visto, no se puede almacenar cualquier tipo de datos. Aunque no es difícil establecer algún tipo de convención para codificar cualquier dato usando los posibles.
- No son modificables, es decir, no tenemos un API para cambiar un único dato en el archivo. Hay que serializar de nuevo toda la estructura y generar el archivo partiendo de cero. Por ello no son adecuadas para grandes cantidades de datos.

### El formato de las *property lists*

Las *property lists* se pueden almacenar en archivos en modo texto o binario. En los ejemplos usaremos sobre todo el modo texto. La extensión típica es `.plist`. En este modo se usa formato XML, aquí tenemos un ejemplo:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>colorFondo</key>
    <array>
        <integer>255</integer>
        <integer>255</integer>
        <integer>0</integer>
    </array>
    <key>fuente</key>
    <string>System</string>
</dict>
</plist>
```

La *raíz* de la estructura de datos puede ser un diccionario, como en nuestro caso, o un array.

Xcode incluye un editor de *property lists* con el que podemos editar los datos de forma "asistida" sin tener que tocar directamente el XML. Creamos una nueva lista con `File > New ` y entre las plantillas elegimos evidentemente `Property list`. Lo primero que hacemos es elegir qué va a ser la *raíz* (array o diccionario) y luego vamos creando "nodos". Para cada uno tecleamos un nombre, elegimos el tipo y tecleamos el valor.

![](img/nodos_plist.gif)

En el caso de los arrays añadimos valores "desplegando" el nodo (con la flechita que aparece a la izquierda, y pulsando sobre el botón del `+`)

![](img/array_plist.gif)

> Podemos también editar el XML en modo texto pulsando con botón derecho sobre el archivo y eligiendo en el menú contextual "Open as > Source Code"

### Leer una property list

Leer una *property list* de un archivo es muy sencillo, ya que las clases `NSDictionary` y `NSArray` tienen inicializadores específicos para ello. Lo único que necesitamos es saber si el nodo raíz es un array o un diccionario, para usar el inicializador apropiado. 

Para recuperar la *property list* del ejemplo anterior, cuyo nodo raíz es un diccionario, haríamos algo como:

```swift
var dict: NSDictionary?
if let path = Bundle.main.path(forResource:"prueba", ofType: "plist") {
    dict = NSDictionary(contentsOfFile: path)
}
//El inicializador devuelve un Optional, tenemos que desenvolverlo
if let unwrappedDict = dict {
   //Al referenciar una clave del diccionario obtenemos también un opcional
   if let fuente = unwrappedDict["fuente"],
      let colorFondo = unwrappedDict["colorFondo"] {
        print("Fondo: \(colorFondo), Fuente: \(fuente)")
   }
}
```

En el ejemplo estamos suponiendo que el archivo se llama `prueba.plist` y que está contenido en el *bundle* de la aplicación. Este es el sitio donde se almacena por defecto cuando creamos un `.plist` en Xcode.

### Guardar una property list

Veamos cómo haríamos el paso inverso: almacenar en un archivo una estructura de datos compatible con una *property list*. Lo primero es tener definida la estructura de datos, que continuando con el ejemplo anterior sería:

```swift
let miDict : [String : Any] = [
    "fuente" : "System",
    "colorFondo" : [255,255,0]
]
```

Nótese que como los valores del diccionario son de tipos heterogéneos, el compilador nos obliga a declarar explícitamente el tipo del diccionario como `[String:Any]`.

> Recordar que en una *property list* las claves de los diccionarios tienen que ser cadenas

Es tan sencillo almacenar la *property list* como fue leerla, lo único que debemos hacer es convertir el diccionario a su clase equivalente en *Foundation* y usar el método `write` para almacenarlo en un archivo.
 
```swift
let miDict : [String : Any] = [
    "fuente" : "System",
    "colorFondo" : [255,255,0]
]
//Obtenemos la URL del directorio "Documents"
var urlDocs = FileManager.default.urls(for:.documentDirectory, 
                                       in:.userDomainMask)[0]
//Formamos la URL del archivo añadiendo a la anterior el nombre del ".plist"                                       
let urlPlist = urlDocs.appendingPathComponent("mi_plist.plist")
//Convertimos a NSDictionary y almacenamos
let miNSDict = miDict as NSDictionary
miNSDict.write(to: urlPlist, atomically: true)
```

Si estamos en el simulador podemos ir al directorio correspondiente a `Documents` y ver el archivo `mi_plist.plist` 

> Recordemos que el *bundle* de la aplicación es solo de lectura, por lo que un .plist almacenado en esta localización no será modificable. La estrategia habitual es hacer que cuando arranque la aplicación se realice una copia en otro directorio con permisos de escritura, típicamente `Documents` y que a partir de entonces se trabaje con esa copia.