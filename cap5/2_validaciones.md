## Validación de datos

Como ya vimos en la sesión anterior, cuando definimos el modelo de datos, para cada entidad podemos especificar una serie de *reglas de validación*, que varían según el tipo de datos: por ejemplo para cadenas podemos indicar una longitud mínima y máxima o una expresión regular, para fechas un rango de fechas válidas, para enteros también un rango, etc.

Eso no quiere decir que no podamos tener un objeto gestionado por Core Data con valores inválidos, ya que de lo único que se asegura el *framework* es que un objeto no válido no se puede guardar en el almacenamiento persistente. Es decir, los errores se disparan al hacer `save` del contexto.

Por ejemplo supongamos que hemos especificado que un `Usuario` debe tener un password de seis caracteres de longitud como mínimo, e intentamos guardar un usuario con un password de menos longitud. Al hacer `save()` se disparará el error. 

```swift
let miDelegate = UIApplication.shared.delegate as! AppDelegate
let miContexto = miDelegate.persistentContainer.viewContext
let usuario = NSEntityDescription.insertNewObject(forEntityName: "Usuario", into: miContexto) as! Usuario
usuario.login = "pepe"
usuario.password = "pepe"
do {
  try miContexto.save()
} catch {
   let nsError = error as NSError
    print("Error \(nsError.code)")
}
```

El objeto `error` contiene bastante información sobre el error producido: un código de error que en este caso será el 1670 (indicando "cadena demasiado corta") y además un diccionario (propiedad `userInfo`) con múltiples datos sobre el error. Por desgracia la información es tediosa de extraer y además es bastante posible que no sea significativa para el usuario por lo que no podemos limitarnos a mostrarla en pantalla.