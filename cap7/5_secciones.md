## Secciones de tabla automáticas

Podemos conseguir generar secciones de modo automático basándonos en alguna propiedad de la entidad sobre la que se hace la *fetch request*. Tiene que ser la misma propiedad que se usa para ordenar o alguna basada en ella, ya que elementos que siguen el orden del listado no pueden ir alternando de sección (las secciones no se repiten).

Al crear el *fetched results controller* especificamos  en el parámetro `sectionNameKeyPath` la propiedad a usar para generar secciones. Por ejemplo, podríamos agrupar los mensajes por el título de la conversación a la que pertenecen.

```swift
self.frc = NSFetchedResultsController<Mensaje>(fetchRequest: consulta, managedObjectContext: miContexto, sectionNameKeyPath: "conversacion.titulo", cacheName: "miCache")
```

En el *datasource* de la tabla tenemos también que implementar el método que genera los títulos de las secciones. El *fetched results controller* los generará por nosotros, de modo que simplemente podemos obtenerlos de él.

```swift
override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.frc.sections![section].name
}
```

