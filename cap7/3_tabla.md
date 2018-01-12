
## Mostrar los datos en la tabla {#mostrar_datos }

Recordemos que las tablas toman los datos de su *datasource*, un objeto que debe implementar una serie de métodos que sirven para devolver el contenido: devolver el número de secciones, devolver el número de filas en una sección y devolver una fila en concreto. El API de *fetched results controller* tiene métodos para hacer precisamente esto, así que en nuestro código nos limitaremos más o menos a "pasarle la pelota".

Para simplificar el ejemplo haremos que el *datasource* de la tabla sea el *view controller*. Vamos a implementar en él los métodos necesarios.

> Si usamos un `UITableViewController`, Xcode habrá generado para nosotros el esqueleto de estos métodos. Por otro lado, automáticamente el *view controller* es el *datasource* de la tabla, conexión que tendríamos que hacer de modo manual si usamos otro tipo de *view controller*.

Primero vamos a ocuparnos del **número de secciones**. La propiedad `sections` del *fetched results controller*, es un array con las secciones de la tabla, así que basta con devolver el tamaño de este array. En realidad por el momento podríamos devolver simplemente `1`, ya que hemos dicho que no tenemos secciones en la tabla, pero vamos a dejar el código preparado para no tener que modificarlo luego.

```swift
override func numberOfSections(in tableView: UITableView) -> Int {
    return self.frc.sections!.count
}
```

Recordemos que `frc` es una propiedad que hemos definido en el *view controller* y que referencia al *fetched results controller*.

El método que devuelve el **número de filas en la sección actual** es solo un poco más complicado

```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.frc.sections![section].numberOfObjects
}
```

Simplemente accedemos a la sección en cuestión y devolvemos su propiedad `numberOfObjects`, que es el número de filas en la sección.

Ya solo nos falta el método más complicado, el que **devuelve una fila dada su posición** o *index path*. En realidad es sencillo de implementar, porque el método `object(at:)` del *fetched results controller* nos devuelve un dato dado su *index path*. Solo tenemos que "empaquetar" la información en una celda.

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //recordar que el prototipo de celda tiene un "reuse identifier"
    //que hay que asignar en el storyboard
    let cell = tableView.dequeueReusableCell(withIdentifier: "miCelda", for: indexPath)
    
    let mensaje = self.frc.object(at: indexPath)
    cell.textLabel?.text = mensaje.texto!
    return cell
}
```

Nótese que cuando inicializamos el *fetched results controller* lo hacemos con el tipo `Mensaje` (como `NSFetchedResultsController<Mensaje>`). Así que cuando obtenemos un objeto con `object(at:)` Swift "sabe" que es un `Mensaje` y no es necesario hacer el *cast*.

Con todo esto ya tenemos la misma funcionalidad que teníamos cuando usábamos arrays para almacenar los datos de la tabla, a partir de ahora vamos a ver qué ventajas adicionales nos da el *fetched results controller* frente a la versión anterior.
