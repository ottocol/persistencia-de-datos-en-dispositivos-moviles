## Persistencia de datos en Firebase

Actualmente hay dos bases de datos disponibles en Firebase: la *realtime* database, que es la "original" y el *cloud firestore*, que se introdujo posteriormente. Ambas son bases de datos NoSQL, aunque la *realtime* tiene una estructura de datos algo más peculiar. Vamos a ver aquí la *realtime database*, que como su nombre indica es especialmente apropiada para aplicaciones en *tiempo real*, ya que además de poder hacer las típicas consultas podemos "escuchar" los cambios en los datos. No obstante se puede usar en cualquier tipo de aplicación.

Podéis consultar *online* y traducida al español la [documentación de los APIs de iOS para la *realtime database*](https://firebase.google.com/docs/database/ios/start).

### Estructurar los datos

Como ya hemos comentado, las dos bases de datos disponibles en Firebase son NoSQL. Esto quiere decir que los datos no tienen la división habitual en tablas a la que estamos acostumbrados en bases de datos relacionales. La base de datos tampoco se ocupa de comprobar automáticamente la consistencia o la integridad de los datos, quedando esta tarea en manos de la aplicación.

En la *realtime database* todos los datos están contenidos en un único "árbol" de pares clave-valor. Los valores pueden ser primitivos (números, cadenas o valores booleanos) o pueden ser valores compuestos a su vez de pares clave-valor.  Por ejemplo podríamos tener algo como:

```json
{
    "personas" : {
        "jap2" : {
            "nombre" : "Juan",
            "apellidos": "Arriquitaun Pérez"
        },
        "ems21" : {
            "nombre" : "Eva",
            "apellidos": "Marín Salgado"
        }
    }
}
```

En este caso el árbol contiene un único par clave/valor en su nivel superior. El valor asociado a la clave "personas" es compuesto y consiste de dos pares cuyas claves son "jap2" y "ems21", y así sucesivamente. Nótese que la clave se separa del valor por ":", que un par se separa del siguiente con una coma y que los valores compuestos se delimitan entre llaves. Es decir, es un formato de datos muy similar a JSON, aunque en JSON se pueden representar listas de datos con `[]` y esa posibilidad no existe aquí. 

Nótese que, al contrario que en las bases de datos relacionales **no existe un *esquema* inicial** que restrinja el formato de los datos. Mientras se respete la estructura básica de pares clave/valor los datos tienen un formato libre. Por ejemplo no necesariamente tendríamos que tener propiedad "nombre" para todas las personas de la BD, o podríamos tener alguna propiedad más para algunas personas sí y para otras no.

Al no existir tablas ni relaciones entre ellas, la forma más habitual de representar las relaciones entre datos es "embeber" unos datos dentro de otros. Por ejemplo:

```json
{
  "personas" : {
    "ems21" : {
      "apellidos" : "Marín Salgado",
      "nombre" : "Eva",
      "mensajes" : {
        "m1" : {
          "texto" : "Hola amigos",
          "timestamp" : 19029898493
        },
        "m2" : {
          "texto" : "¿No me contesta nadie? :(",
          "timestamp" : 20458569556
        }
      }
    },
    "jap2" : {
      "apellidos" : "Arriquitaun Pérez",
      "direccion" : {
        "calle" : "Pez, 25",
        "localidad" : "Madrid"
      },
      "mensajes" : {
        "m3" : {
            "texto": "Hola, sí!!"
            "timestamp" : 21020129382
        }
      },
      "nombre" : "Juan"
    }
  }
}
```

En el código anterior podemos ver algunos de ejemplos de lo que en bases de datos relaciones serían precisamente relaciones. Por un lado una relación 1:1 entre "persona" y "direccion", que se reperesenta aquí con la propiedad compuesta "direccion" dentro de la persona. Por otro lado una relación 1:N entre "persona" y "mensajes", que se representa de la misma forma, guardando los "mensajes" dentro de la "persona".

El problema de las estructuras de datos anidadas es a la hora de sacar la información de la BD. Como veremos, con Firebase podemos listar y filtrar de forma sencilla todos los nodos hijos de un nodo dado (por ejemplo *obtener todos los mensajes de la persona "ems21" ordenados por timestamp*). El problema lo tendríamos si quisiéramos obtener una lista de todos los mensajes independientemente de quién los ha enviado, que con la estructura de datos anterior requeriría ejecutar una consulta por cada usuario para finalmente unir todos los resultados y ordenarlos.

Este problema se puede resolver *desnormalizando* los datos, es decir, duplicando la información. Además de la estructura anterior podríamos tener repetidos por otro lado todos los mensajes dentro de un nodo "mensajes" independientemente de quién los haya enviado:

```json
{
  "personas" : {
    //Igual que antes, personas con sus mensajes
  }
  "mensajes" : {
    //Aquí todos los mensajes de todos los usuarios
  }

}

```

### Referencias

Un concepto fundamental y necesario para poder leer y escribir datos es el de *referencia*. Una *referencia* representa un nodo del árbol de datos. Con los métodos del API podemos obtener directamente una referencia a un nodo cualquiera si conocemos su *path* desde la raíz. O bien podemos partir de una referencia que ya tengamos a un nodo y movernos a uno de sus hijos. Una vez obtenida la referencia al nodo que nos interesa, podremos leer su estado/modificarlo con otros métodos del API.

Por ejemplo supongamos que tenemos la estructura de datos en Firebase que vimos en el apartado anterior.

```json
{
    "personas" : {
        "jap2" : {
            "nombre" : "Juan",
            "apellidos": "Arriquitaun Pérez"
        },
        "ems21" : {
            "nombre" : "Eva",
            "apellidos": "Marín Salgado"
        }
    }
}
```

Para obtener una referencia a un nodo, lo primero es obtener la base de datos en sí, a la que accedemos con `Database.database()`. A partir de aquí:

- El nodo raíz lo podemos obtener con `reference()`, y podemos ir bajando por los hijos con `child()`, por ejemplo:

```swift
//El árbol completo, dicho de otro modo el nodo raíz
let rootRef = Database.database().reference()
//El nodo "personas"
let personasRef = rootRef.child("personas")
//El nodo "nombre" perteneciente a "jap2"
let nombreRef = personasRef.child("jap2").child("nombre")
```

- También podemos acceder a un nodo con su *path* desde el nodo raíz, para ello usamos el método `reference(withPath:)`, por ejemplo:

```swift
let db = Database.database()
//El nodo "nombre" perteneciente a "jap2"
let nombreRef = db.reference(withPath:"personas/jap2/nombre")
```

Nótese que podemos obtener una referencia a un nodo aunque este no exista todavía en la base de datos. Por ejemplo, esto sería válido en el ejemplo que estamos siguiendo, aunque en la BD no hay nada relativo a pedidos:

```swift
let ref = db.reference(withPath("pedidos/1"))
```

Esto nos permitirá crear un nuevo pedido cuyos datos sean hijos del nodo "pedidos/1" sin necesidad de haber creado previamente los nodos intermedios.

### Crear y actualizar datos

Para **modificar un nodo** usamos `setValue(<nuevovalor>)` sobre su referencia. Este método es destructivo, ya que sustituye completamente el valor actual del nodo, incluso aunque este tenga otros nodos hijos. Por ejemplo:

```swift
let db = Database.database()
let nombreRef = db.reference(withPath:"personas/jap2/nombre")
//El nombre cambia de Juan a John
nombreRef.setValue("John")
//CUIDADO, sustituye el valor de "personas", con todo lo que hay por debajo
let personasRef = db.reference(withPath:"personas")
personasRef.setValue("La que has liao, pollito")
```

Nótese que el segundo cambio modifica el valor de un nodo compuesto, sustituyendo todo lo que hay "por debajo", así que el árbol quedaría

```swift
{
    "personas" : "La que has liao, pollito"
}
```

También podemos **crear un nodo aunque los nodos intermedios no existan**

```swift
self.db = Database.database()
//Este nodo no existe, pero vamos a usar la referencia para crear un valor
let mlmj15 = db.reference(withPath: "personas/mlmj15")
mlmj15.setValue(["nombre":"María Luisa", "apellidos":"Marín Juárez"])
```

El resultado sería:

```json
{
  "personas" : {
    "mlmj15" : {
      "apellidos" : "Marín Juárez",
      "nombre" : "María Luisa"
    }
  }
}
```

En los ejemplos anteriores hemos asignado un nuevo valor que es un dato primitivo, pero también podría ser **asignar un valor compuesto, basta con pasar un diccionario**. Por ejemplo, Podríamos cambiar los datos de "mlmj15" con:

```swift
let db = Database.database()
let ref = db.reference(withPath:"personas/mlmj15")
ref.setValue(["nombre":"Mari Loli", "apellidos":"Martínez Jaén"])
```

**En lugar de sobreescribir totalmente un nodo podemos actualizar solo algunas de sus propiedades** con `updateChildValues`

```swift
let db = Database.database()
let ref = db.reference(withPath:"personas/mlmj15")
ref.updateChildValues(["nombre":"M.L."])
```

En este ejemplo estamos usando un identificador generado manualmente para cada persona, pero en muchos casos necesitaremos generar el identificador automáticamente. Podemos hacerlo con `childByAutoId`.

```swift
let db = Database.database()
let personasRef = db.reference(withPath:"personas")
let nuevoIdRef = personasRef.childByAutoId()
nuevoIdRef.setValue(["nombre":"Luis Ricardo", "apellidos":"Borriquero"])
```

quedando algo como:

```json
{
  "personas" : {
    "L33iv1bhzKkFkQd_ff4" : {
      "apellidos" : "Borriquero",
      "nombre" : "Luis Ricardo"
    },
    ...
  }
}
```

El algoritmo de generación de ids asegura que no va a haber colisiones entre los identificadores generados por los distintos clientes. Además el *id* incluye un *timestamp*, de modo que si ordenamos por *id* estamos ordenando implícitamente por orden de inserción en la base de datos.

Finalmente, podemos **borrar datos** con `removeValue()`. También podríamos hacer `setValue(nil)`, o poner a `nil` alguna propiedad en `updateChildValues`.

### Consultas

La *realtime Database*, como su propio nombre indica, tiene funcionalidades apropiadas para aplicaciones que necesitan datos en tiempo real. En concreto **podemos *escuchar* los cambios en los datos**. Como luego veremos podemos usar este API también para hacer consultas al estilo más clásico, que simplemente devuelvan el estado actual de la BD.

Para observar los cambios en los datos de un nodo, incluyendo también todos los nodos que hay "por debajo", podemos usar `observe(_,withBlock:)`, donde el último parámetro es una clausura a ejecutar cuando se produzca el evento. Por ejemplo:

```swift
let db = Database.database()
let personasRef = db.reference(withPath:"personas")
personasRef.observe(.value) {
    snapshot in
    print("Algo ha cambiado en \(snapshot.value)")
}
```

El parámetro de la clausura es un objeto de tipo `DataSnapshot`, que representa un *snapshot* de un fragmento de datos en un determinado momento.

> Hay que llevar cuidado con el nivel en el que estamos escuchando, ya que se detectará cualquier cambio en los niveles que hay por debajo y esto puede ser costoso para los niveles superiores del árbol.

La clausura se llamará una vez con el valor actual de la BD y a partir de ese momento, de nuevo cada vez que se produzca un cambio. Para dejar de "escuchar" los cambios podemos usar `removeObserverWithHandle()`. A este método hay que pasarle el *handle* del listener creado por `observe`. Este *handle* lo devuelve el método *observe*, aunque en el ejemplo anterior hemos ignorado el valor. De modo que haríamos algo como:

```swift
...
//añadimos el "listener" y nos guardamos el handle
let handle = personasRef.observe(.value) {
    ...
}
//eliminamos el "listener" anterior usando el handle
personasRef.removeObserver(withHandle: handle)
//también podríamos hacer esto para eliminar todos los listener sobre personasRef
personasRef.removeAllObservers()
```

Podemos escuchar otros eventos, no solo los cambios de valor. En concreto, podemos saber cuándo ha cambiado algún hijo de un nodo dado (ha sido añadido, modificado o borrado). En ese caso el *snapshot* solo contendrá el nodo que ha cambiado. Por ejemplo, así podríamos saber si ha sido insertado un nuevo nodo que sea hijo del nodo "personas":

```swift
self.db = Database.database()
let personasRef = db.reference(withPath:"personas")
personasRef.observe(.childAdded) {
   snapshot in
   print("\(snapshot.key)=\(snapshot.value)")
}
```

También podemos hacer consultas más clásicas, en las que simplemente queremos conocer el estado actual de la base de datos pero no nos interesan los sucesivos cambios. Podemos hacerlo sustituyendo `observe` por `observeSingleEvent`. Por lo demás el código es igual:

```swift
self.db = Database.database()
let personasRef = db.reference(withPath:"personas")
personasRef.observeSingleEvent(.childAdded) {
   snapshot in
   print("\(snapshot.key)=\(snapshot.value)")
}
```



