1_

- supongamos una operación muy costosa que implique a Core Data, por ejemplo obtener datos de un servidor. No se puede hacer en el hilo principal porque bloquearía el UI
- solución en principio: hacerla en una cola en background. Problema, Core Data no es thread-safe

How can you fix this? The traditional way would be to use Grand Central Dispatch to run the export operation on a background queue. However, Core Data managed object contexts are not thread-safe. That means you can’t just dispatch to a background queue and use the same Core Data stack.
 Core Data by Tutorials Second Edition Chapter 10: Multiple Managed Object Contexts

“Core Data has a straightforward concurrency model: the managed object context and its managed objects must be accessed only from the context’s queue. Everything below the context — i.e. the persistent store coordinator, the persistent store, and SQLite — is thread-safe and can be shared between multiple contexts.”

Fragmento de: Florian Kugler. “Core Data”. iBooks. 

El tutorial del surfjournal pero actualizado para iOS10 y PersistentContainer
https://www.raywenderlich.com/145877/core-data-tutorial-multiple-managed-object-contexts-2

http://holko.pl/2016/06/23/core-data/

