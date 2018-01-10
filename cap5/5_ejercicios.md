## Ejercicios de la sesión


En esta sesión vamos a continuar trabajando sobre la aplicación de notas de la primera sesión de Core Data. Necesitarás que esa sesión esté terminada para poder continuar en ella.

> Antes de ponerte a hacer las modificaciones de esta sesión asegúrate de que has hecho un `commit` con el mensaje `terminada sesión 3`. También puedes hacer un `.zip` con el proyecto, llamarlo `notas_sesion_3.zip` y adjuntarlo en las entregas de la asignatura. Así cuando se evalúe el ejercicio el profesor podrá consultar el estado de la aplicación antes de estos ejercicios.

### Usar la clase `Nota` (1 punto)

Modifica el código que tenías de Core Data para que use la clase `Nota`, que habrá generado automáticamente Xcode. Es decir:

- Para crear una nota, en lugar de `insertNewObject` puedes usar el inicializador `Nota(context:)`.
- Cuando accedas a los atributos lo puedes hacer directamente en vez de con `set(value:forKey)` y `value(forKey:)` 

```swift
//En vez de...
nuevaNota.set(value:"EL TEXTO QUE HAGA FALTA ASIGNAR", forKey:"texto")

//ahora sería
nuevaNota.fecha = "EL TEXTO QUE HAGA FALTA ASIGNAR"
```

### Validación de datos (2 puntos)

Queremos validar que la nota no esté vacía antes de guardarla. Para ello:

1. En el modelo, ve a la entidad `Nota`, atributo `texto` y en el panel de propiedades de la derecha, en la validación, pon 1 como longitud mínima.
2. Captura los errores de validación del `save` con un `do...catch let error as NSError`. El error que nos interesa tiene el código 1670, correspondiente a la constante `NSNSValidationStringTooShortError`. Puedes mostrar el error en el campo de texo donde se muestra el mensaje de "nota guardada"
3. En el `catch`, si la nota no tiene longitud válida, además de mostrar el error debes descartar el objeto pendiente de guardar. Puedes hacerlo con

```swift
miContexto.refresh(nuevaNota, mergeChanges: false)
```

que sincroniza el objeto con la BD, en este caso como la nota todavía no está guardada, descarta los cambios.

### Transformables (3 puntos)

Vamos a añadirle a cada nota un campo que sea un array de *tags*, o palabras clave, dicho de otro modo. Es decir, un array de Strings.

1. Añade el campo, llamado `tags` en el editor del modelo. Asígnale como tipo `transformable`
2. Vuelve a generar las clases para `Nota`. En `Nota+CustomDataProperties.swift` modifica el tipo del campo `tags` para que sea `[String]`, así no tendrás que andar haciendo *casts* manualmente a y desde `NSObject`
3. En la interfaz de usuario de alta de nota añade un campo de texto más. Allí el usuario debe escribir las *tags* como una lista de palabras separadas por espacios
4. Para pasar de una cadena separada por espacios a un array de Strings puedes usar el método de la clase `String` llamado `components(separatedBy:)`, que aplicado sobre una cadena la divide por la cadena "separadora" generando un array

```swift
"hola mundo".components(separatedBy:" ")  //devolvería ["hola", "mundo"]
```
