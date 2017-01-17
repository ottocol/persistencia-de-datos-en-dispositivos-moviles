
## Notificaciones del ciclo de vida


Los objetos gestionados van pasando por distintos cambios. Primero son creados u obtenidos de la base de datos con un *fetch*, luego se modifican sus valores y en algún momento se guardan. En muchos casos nos interesará enterarnos de cuándo se realizan estas operaciones. Por ejemplo saber cuándo se crea un objeto puede ser útil para inicializar valores por defecto, o saber cuándo se modifica un atributo para actualizar la interfaz de usuario.

**Cuando se crea un nuevo objeto gestionado**, Core Data llama a su método `awakeFromInsert`. El uso típico de este método, como ya hemos comentado, es el de fijar valores por defecto que no se pueden fijar a través de la interfaz gráfica de Xcode, ya que esta solo permite especificar valores constantes. Por ejemplo, vamos a ver cómo haríamos para asignar la fecha actual a un `Mensaje` al crearlo.

Para no tocar las clases de entidades generadas por Xcode, y que podría ser necesario borrar y volver a crear, lo hacemos en una extensión propia a la clase `Mensaje`. El nombre del archivo es arbitrario.

```swift
//Archivo Mensaje+Custom.swift
import Foundation
import CoreData

extension Mensaje {
    override public func awakeFromInsert() {
        self.fecha = Date() as NSDate
    }
}
```

> El *cast* con `as NSDate` lo usamos porque al generar las clases para las entidades con Xcode es el tipo que usa por defecto para fechas. Podríamos modificar manualmente el archivo `Mensaje+CoreDataProperties.swift` y cambiar el `NSDate` por un `Date` para ahorrarnos el *cast*, pero tendríamos que hacer el cambio cada vez que generáramos la clase.

Aunque suele ser menos útil que el anterior, también podemos enterarnos de **cuándo se ha instanciado un objeto a través de un *fetch*** sobreescribiendo el método `awakeFromFetch()`.

Core Data propiamente dicho no incorpora ningún mecanismo para saber **cuándo se ha modificado un atributo** de un objeto gestionado, pero no lo necesita, porque iOS ya tiene un mecanismo genérico: el KVO o *Key Value Observing*. Con este mecanismo podemos detectar cambios en las propiedades de cualquier objeto que herede de `NSObject`. Además las propiedades a observar deben estar marcadas como `dynamic` ([explicación en la documentación de Apple](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID57). Estos son requerimientos que limita su utilidad para trabajar con objetos genéricos Swift. Como `NSManagedObject` ya hereda de éste y sus propiedades son `dynamic`, no tenemos que hacer ningún esfuerzo adicional para usar KVO con objetos gestionados.

KVO es una implementación del patrón de diseño *Observer*. Para usar KVO necesitamos un objeto que pueda ser observado (el objeto gestionado) y otro que actúe como observador. El observador está "suscrito" a cambios en una propiedad del objeto observado.

```swift
//decimos que queremos observar al objeto gestionado
usuario.addObserver(self, forKeyPath:"password", options: .new, context:nil)
```

Los parámetros indican lo siguiente:

- El primero es el objeto que va a actuar de observador. En el ejemplo anterior, `self`, o sea el objeto donde reside este código que se estaba ejecutando. Aunque puede ser cualquiera
- El segundo indica la propiedad que queremos observar
- El tercero es un conjunto de *flags* que se pueden combinar con `|` y que indican qué valores quiere recibir el observador. En el ejemplo estamos diciendo que solo queremos conocer el nuevo `password`, pero ya no sabremos cuál era el antiguo. Si por ejemplo quisiéramos ambos podríamos pasar `.old | .new`
- El último parámetro se usa raras veces. Se recomienda consultar la documentación de Apple.

El objeto observador debe también heredar de `NSObject`. Los eventos observables los recibirá como llamadas al método `observeValue(forKeyPath:of:change:context:)`.

- El primer parámetro es la propiedad que ha cambiado
- El segundo el objeto para el que ha cambiado la propiedad. Estos datos son necesarios porque un mismo observador podría estar observando varios objetos, y varias propiedades de cada uno
- El tercero es el más complejo, y es un diccionario con los valores del cambio. Las claves son constantes que indican el tipo de valor. Por ejemplo, `NSKeyValueChangeKey.newKey` indica el nuevo valor de la propiedad, y `NSKeyValueChangeKey.oldKey` indica el antiguo. Los valores que tengamos o no en el diccionario dependerán de lo que habíamos especificado en el parámetro `options` al suscribirnos.


Por ejemplo:

```swift
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "password" {
        let nuevoPassword = change?[.newKey]
        print("El nuevo password es \(nuevoPassword)")
    }
}
```

Otra posibilidad para observar el ciclo de vida de los objetos gestionados es usar **notificaciones**. Por ejemplo, cada vez que un objeto se inserta, actualiza o borra en un contexto de persistencia, emite una notificación de tipo `NSManagedObjectContextObjectsDidChangeNotification`. Más sobre esto en [este tutorial](https://cocoacasts.com/how-to-observe-a-managed-object-context/).
