## Refrescar la tabla

Tal y como está ahora el código si creamos un nuevo mensaje este no aparece en la tabla. Pero podemos resolverlo de forma sencilla con el *fetched results controller*, ya que este está “suscrito” a los cambios que se producen en el contexto de persistencia, siempre que afecten a los contenidos en su *fetch request*. 

El *fetched results controller* avisará a su vez de estos cambios a su *delegate*. Para simplificar, haremos que este sea el *view controller*, aunque podría ser cualquier clase.

```swift
//En el viewDidLoad, tras crear el fetched results controller
self.frc.delegate = self;
```

> Lo anterior, en lugar de por código, se puede hacer gráficamente en Xcode con el *connections inspector*.

Por tanto tendremos que pasar a implementar el protocolo correspondiente, ya que el *fetched results controller* llamará a una serie de métodos cuando se modifique el contexto. Lo primero es indicarlo en la cabecera de la clase:

```swift
import UIKit
import CoreData

class MiController : UITableViewController, NSFetchedResultsControllerDelegate {
 ...
}
```

El protocolo tiene cuatro métodos que vamos a ver a continuación.

Cuando se van a modificar los datos y cuando ya se han modificado el *fetched results controller* avisará a su *delegate* llamando a `controllerWillChangeContent` y `controllerDidChangeContent`, respectivamente. Podemos aprovechar estos dos métodos para llamar al `beginUpdates()` y `endUpdates` de la tabla. De este modo si se modifican varias filas "de golpe" la animación se hará de forma conjunta.


```swift
func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
}

func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
}
```

Cuando se ha modificado algún objeto del contexto y esta modificación afecte a los resultados del *fetched results controller* se llamará al método más complejo del protocolo: `controller(_:didChange:at:for:newIndexPath:)`. El código del método va a ser algo largo porque aquí tenemos que tratar con los cuatro tipos de modificaciones posibles: `.insert`, `.move`, `.delete` y `.update`.

```swift
func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
        self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
    case .update:
        self.tableView.reloadRows(at: [indexPath!], with: .automatic)
    case .delete:
        self.tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .move:
        self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
    }
}
```

Como vemos, el código es bastante directo, simplemente hay que trasladar a la vista de tabla lo que nos está diciendo el *fetched results controller*: si se ha insertado un dato insertamos una fila, si se ha borrado la borramos, etc. 

El último de los métodos del protocolo se usa cuando se modifican las secciones de la tabla. Todavía no hemos visto cómo decirle al *fetched results controller* que cree una tabla con secciones, pero no lo necesitamos para ver ya cómo se modifican.


```swift
func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch(type) {
    case .insert:
        self.tableView.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
    case .delete:
        self.tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
    default: break
    }
}
```