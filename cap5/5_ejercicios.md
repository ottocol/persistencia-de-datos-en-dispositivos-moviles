## Ejercicios de la sesión


En esta sesión vamos a continuar trabajando sobre la aplicación de notas de la primera sesión de Core Data. Necesitarás que esa sesión esté terminada para poder continuar en ella.

> Antes de ponerte a hacer las modificaciones de esta sesión asegúrate de que has hecho un `commit` con el mensaje `terminada sesión 3`. También puedes hacer un `.zip` con el proyecto, llamarlo `notas_sesion_3.zip` y adjuntarlo en las entregas de la asignatura. Así cuando se evalúe el ejercicio el profesor podrá consultar el estado que tenía la aplicación antes de estos ejercicios.


### Añadir la clase `Nota` (0,2 puntos)

Para realizar estos ejercicios lo primero que tienes que hacer es añadir una clase `Nota` que represente a la entidad `Nota`. Recuerda que Xcode lo puede hacer por tí, seleccionando la entidad en el editor del modelo y con la opción `Editor > Create managed object subclass...`.

En el panel de la derecha asegúrate que en `Module` aparece `Global Namespace` (es lo que aparece si borras el contenido del campo) y en `codegen` `Manual/none`. Si lo haces automático luego no podrás modificar el código de la clase.

**Al menos en la parte de creación de notas** modifica el código que tenías para que use la clase `Nota`. Cuando crees el objeto con `insertNewObject` tendrás que hacer el *cast* a `Nota`

```swift
let nuevaNota = NSEntityDescription.insertNewObject(forEntityName: "Nota", into: miContexto) as! Nota
```

Y cuando accedas a los atributos ya lo puedes hacer directamente en vez de con `set(value:forKey)` y `value(forKey:)` 

```swift
//En vez de...
nuevaNota.set(value:"EL TEXTO QUE HAGA FALTA ASIGNAR", forKey:"texto")

//ahora sería
nuevaNota.fecha = "EL TEXTO QUE HAGA FALTA ASIGNAR"
```

### Transformables (0,6)

Vamos a añadirle a cada nota un campo que sea un array de *tags*, o palabras clave, dicho de otro modo. Es decir, un array de Strings.

1. Añade el campo, llamado `tags` en el editor del modelo. Asígnale como tipo `transformable`
2. Vuelve a generar las clases para `Nota`. En `Nota+CustomDataProperties.swift` modifica el tipo del campo `tags` para que sea `[String]`, así no tendrás que andar haciendo *casts* manualmente a y desde `NSObject`
3. En la interfaz de usuario de alta de nota añade un campo de texto más. Allí el usuario debe escribir las *tags* como una lista de palabras separadas por espacios
4. Para pasar de una cadena separada por espacios a un array de Strings puedes usar el método de la clase `String` llamado `components(separatedBy:)`, que aplicado sobre una cadena la divide por la cadena "separadora" generando un array

```swift
"hola mundo".components(separatedBy:" ")  //devolvería ["hola", "mundo"]
```

### Ciclo de vida de los objetos (0,1)

En la clase `Nota`, sobreescribe el método `awakeFromInsert` para que al crear una nota se le asigne la fecha actual (`Date()`)

