## Ejercicios de arquitecturas iOS, parte I

En la aplicación de Notas que venimos desarrollando en la asignatura, el *view controller* `ListaNotasController` tiene demasiadas funcionalidades.

**(4 puntos)** Separa los métodos que implementan el *datasource* de la tabla en una clase aparte:
  - Crea la clase `ListaNotasDatasource`:
    - Añádele un método `setLista()` que reciba un array de notas (`[Nota]`) como parámetro y se lo guarde en una propiedad de la clase llamada `listaNotas`
    - Llévate a esta clase el código de los métodos que implementan el *datasource*
  - En el `ListaNotasViewController`
    - Añade una propiedad  `ds`, de tipo `ListaNotasDataSource` 
    - En el `viewDidLoad`, haz que el `ds` sea el *datasource* de la tabla

    ```swift
    self.tableView.dataSource = self.ds
    ```

    - En el `viewWillAppear`, cada vez que obtengas la lista de notas con el *fetch request*, pásaselas al `ds`, con `ds.setLista()`
    - La propiedad `listaNotas` del `ListaNotasViewController` ya sobra, porque la lista ahora la maneja el *datasource*
