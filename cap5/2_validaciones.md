## Validación de datos

Como ya vimos en la sesión anterior, cuando definimos el modelo de datos, para cada entidad podemos especificar una serie de *reglas de validación*, que varían según el tipo de datos: por ejemplo para cadenas podemos indicar una longitud mínima y máxima o una expresión regular, para fechas un rango de fechas válidas, para enteros también un rango, etc.

Eso no quiere decir que no podamos tener un objeto gestionado por Core Data con valores inválidos, ya que de lo único que se asegura el *framework* es que un objeto no válido no se puede guardar en el almacenamiento persistente. Es decir, los errores se disparan al hacer `save` del contexto.

Por ejemplo supongamos que hemos especificado que un `Usuario` debe tener un "nivel de usuario" como mínimo de 0, y supongamos que intentamos guardar un usuario con "nivel" negativo. Al hacer `save()` se disparará el error. 

```swift
let miDelegate = UIApplication.shared.delegate as! AppDelegate
let miContexto = miDelegate.persistentContainer.viewContext
let usuario = NSEntityDescription.insertNewObject(forEntityName: "Usuario", into: miContexto) as! Usuario
usuario.nivel = -1
do {
  try miContexto.save()
} catch let miError as NSError {
   if (miError.code == NSValidationNumberTooSmallError) {
        print("El nivel de usuario no es válido")
   }
}
```

El objeto `error` contiene bastante información sobre el error producido: un código de error que en este caso será el 1670 (indicando "número demasiado pequeño") y además un diccionario (propiedad `userInfo`) con múltiples datos sobre el error. En lugar de usar los códigos numéricos de error podemos usar una serie de constantes que comienzan por `NSValidation`, en este caso `NSValidationNumberTooSmallError` indica que es un valor demasiado pequeño.

Podemos escribir nuestros propios validadores añadiéndole a la clase de la entidad un método `validate<nombre_del_atributo>`, o sea si el atributo se llama `texto` el método sería `validateTexto`. Este método debe lanzar una excepción si el objeto no es válido. Podéis ver un ejemplo de este tipo de validación en [este tutorial](https://code.tutsplus.com/tutorials/data-validation-with-core-data-advanced-constraints--cms-26623).