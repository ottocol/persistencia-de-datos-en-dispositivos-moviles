# Ejercicio: uso de fetched results controller

> Las modificaciones de estos ejercicios no afectan al código de las sesiones anteriores, así que no es necesario que hagas ninguna copia del estado del proyecto antes de empezar con esta sesión.

Vamos a ampliar la dichosa aplicación de notas para que use un *fetched results controller*. Para no afectar a lo ya hecho, haremos una tercera pantalla con un listado de todas las notas usando un `FetchedResultsController` (no es necesario implementar búsqueda como tienes en el otro listado)

## Interfaz gráfico (1)

Crea una nueva pantalla de tipo `Table View Controller`. Conecta la primera pantalla a esta (`Ctrl+Arrastrar` y elegir como tipo de *segue* `View Controllers`). Al final en la aplicación tendrás un *tab bar* con tres opciones.

> Haz una tercera pantalla, no cambies la que tenías para que no se pierda el código que hiciste en la sesión anterior. Evidentemente en una aplicación "normal" no tendría sentido tener dos pantallas con la lista de notas.

Para esta pantalla, crea una nueva clase `ListaNotasCDController` ("CD" de “Core Data”) que herede de `UITableViewController`. Recuerda que para que tu clase herede de una de iOS lo más sencillo es usar la plantilla "Cocoa Touch Class". 

Recuerda hacer en el *storyboard* que esta clase sea el *controller* de esta pantalla. Para ello, selecciona la pantalla de listado de notas (*clic* en el primero de los iconos de la barra superior, el de fondo amarillo)  y en el Identity Inspector ( tercero de los iconos del área de la derecha), como "Custom Class" elige `ListaNotasCDController`.

![](img/set_controller.png)

## Implementación (5)

Siguiendo el código de los apuntes y las transparencias **usa un *fetched results controller* para mostrar todas las notas en la tabla**. De momento cuando se inserten notas nuevas la lista no se actualizará. Consulta los apartados ["inicializar el fetched results..."](./2_configuracion_basica.html) y ["mostrar los datos en la tabla"](./3_tabla.html).

Una vez tengas el listado básico vamos a intentar que cuando se modifiquen notas se muestren en la tabla. Para esto **hay que implementar lo que aparece en la sección ["Refrescar la tabla"](https://ottocol.gitbooks.io/persistencia-de-datos-en-dispositivos-moviles/content/cap7/4_refrescar_tabla.html)** de los apuntes. Comprueba que cuando insertamos una nota nueva en la pantalla de notas se muestra en la lista del *fetched results controller*
 
Para ver cómo se modifican las filas "en directo", haz que se puedan borrar notas haciendo *swipe to delete* en la tabla. Para que funcione este gesto, hay que implementar el método

```swift
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let miDelegate = UIApplication.shared.delegate as! AppDelegate
            let miContexto = miDelegate.persistentContainer.viewContext
            //FALTA: eliminar del contexto el objeto en la pos. indexPath
            //Tenéis que obtenerlo del fetched results controller
            //parecido a como se hace para pintar la celda
            ...
            //guardamos el contexto
            try! miContexto.save()
        }
}
```

Ahora puedes probar a borrar una celda y ver cómo al eliminar el objeto del contexto se actualiza en la tabla.

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