# Ejercicio: uso de fetched results controller

Vamos a ampliar la dichosa aplicación de notas para que use un *fetched results controller*.

> Las modificaciones de estos ejercicios no afectan al código de las sesiones anteriores, así que no es necesario que hagas ninguna copia del estado del proyecto antes de empezar con esta sesión.

## Interfaz gráfico (0,2)

Añade una tercera pantalla (un `Table View Controller`) a la aplicación de notas en la que se vea un listado de todas las notas usando un `NSFetchResultsController` (no es necesario implementar búsqueda). Conecta la primera pantalla a esta (`Ctrl+Arrastrar` y elegir como tipo de *segue* `View Controllers`). Al final en la aplicación tendrás un *tab bar* con tres opciones.

> Haz una tercera pantalla, no cambies la que tenías para que no se pierda el código que hiciste en la sesión anterior. Evidentemente en una aplicación "normal" no tendría sentido tener dos pantallas con la lista de notas.

Para esta pantalla, crea una nueva clase `ListaNotasCDController` (de “Core Data”) que herede de `UITableViewController`. Recuerda que para que tu clase herede de una de iOS lo más sencillo es usar la plantilla "Cocoa Touch Class". 

Recuerda hacer en el *storyboard* que esta clase sea el *controller* de esta pantalla. Para ello, selecciona la pantalla de listado de notas (*clic* en el primero de los iconos de la barra superior, el de fondo amarillo)  y en el Identity Inspector ( tercero de los iconos del área de la derecha), como "Custom Class" elige `ListaNotasCDController`.

![](img/set_controller.png)

## Implementación (0,8)

- Siguiendo el código de los apuntes y las transparencias haz que se use un *fetched results controller* para mostrar todas las notas.

- Una vez tengas el listado básico consigue que cuando se inserte una nueva nota aparezca en la tabla
 
- Luego, haz además que se puedan borrar notas haciendo *swipe to delete* en la tabla.

- Finalmente, haz que la tabla tenga secciones automáticas según la primera letra del texto de cada nota. Para ello puedes crear una extensión de la clase `Nota` y añadirle una propiedad calculada llamada `inicial` que devuelva solo esta:

```swift
//Archivo Nota+Custom.swift
import Foundation

extension Nota {
    //Devuelve una subcadena solo con la primera letra del texto
    var inicial: String? {
        if let textoNoNil = self.texto {
            let pos2 = textoNoNil.index(after: textoNoNil.startIndex)
            return textoNoNil.substring(to:pos2)
        }
        else {
            return nil
        }
    }
}
```

Tendrás que cambiar el `NSSortDescriptor` que usas para definir el *fetched results controller* para que asegure que las notas no se "crucen" de sección. Ten en cuenta que si las sigues ordenando por fecha podría haber una que comience por "a", otra por "b" y luego otra por "a" otra vez, y eso no tendría sentido de cara a las secciones. Puedes conseguir que no haya problema si ordenas por texto en vez de por fecha.