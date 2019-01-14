## Ejercicios de la sesión


En esta sesión vamos a continuar trabajando sobre la aplicación de notas de la primera sesión de Core Data. Necesitarás que esa sesión esté terminada para poder continuar en ella.

> Antes de ponerte a hacer las modificaciones de esta sesión asegúrate de que has hecho un `commit` con el mensaje `terminada sesión 3`. También puedes hacer un `.zip` con el proyecto, llamarlo `notas_sesion_3.zip` y adjuntarlo en las entregas de la asignatura. Así cuando se evalúe el ejercicio el profesor podrá consultar el estado de la aplicación antes de estos ejercicios.

### Usar la clase `Nota` (1 punto)

Modifica el código que tenías de Core Data para que use la clase `Nota`, que habrá generado automáticamente Xcode. Es decir:

- Para crear una nota, en lugar de `insertNewObject` puedes usar el inicializador `Nota(context:)`.
- Cuando accedas a los atributos lo puedes hacer directamente en vez de con `set(value:forKey)` y `value(forKey:)` 

```swift
//En vez de...
nuevaNota.set(value:"EL TEXTO QUE HAGA FALTA ASIGNAR", forKey:"texto")

//ahora sería
nuevaNota.fecha = "EL TEXTO QUE HAGA FALTA ASIGNAR"
```

### Validación de datos (1.5 puntos)

Queremos validar que la nota no esté vacía antes de guardarla. Para ello:

1. En el modelo, ve a la entidad `Nota`, atributo `texto` y en el panel de propiedades de la derecha, en la validación, pon 1 como longitud mínima.
2. Captura los errores de validación del `save` con un `do...catch let error as NSError`. El error que nos interesa tiene el código 1670, correspondiente a la constante `NSNSValidationStringTooShortError`. Puedes mostrar el error en el campo de texo donde se muestra el mensaje de "nota guardada"
3. En el `catch`, si la nota no tiene longitud válida, además de mostrar el error debes descartar el objeto pendiente de guardar. Puedes hacerlo con

```swift
miContexto.refresh(nuevaNota, mergeChanges: false)
```

que sincroniza el objeto con la BD, en este caso como la nota todavía no está guardada, descarta los cambios.

### Transformables (1.5 puntos)

Vamos a añadirle a cada nota un atributo que sea un array de *tags*, o palabras clave. Es decir, un array de Strings.

1. Añade el atributo, llamado `tags` en el editor del modelo. Asígnale como tipo `Transformable`
2. En las propiedades del atributo, en el cuadro de texto `Custom class` puedes teclear el tipo deseado. Por defecto es `NSObject`, simplemente un objeto cualquiera (algo así como el `Any` de Swift). Cámbialo tecleando `[String]`
3. En la interfaz de usuario de alta de nota añade un campo de texto más. Allí el usuario debe escribir las *tags* como una lista de palabras separadas por espacios
4. Para pasar de una cadena separada por espacios a un array de Strings puedes usar el método de la clase `String` llamado `components(separatedBy:)`, que aplicado sobre una cadena la divide por la cadena "separadora" generando un array

```swift
"hola mundo".components(separatedBy:" ")  //devolvería ["hola", "mundo"]
```

Haz que la lista de *tags* aparezca en la lista de notas, pero ahora separadas por comas:

1. Tendrás que cambiar el prototipo de la celda por un tipo que tenga texto de "detalle" (cualquiera que no sea `Basic`). 
2. En el método `tableView(_:, cellForRowAt:)`  del `ListaNotasController`, la etiqueta de detalle es la propiedad `cell.detailTextLabel`. Como texto de la etiqueta pon la lista de *tags* como un único String donde estén separadas por barras. Puedes usar `joined` para componer un String a partir de un array de Strings (es como el "inverso" del método `components` que usaste antes)

```swift
let miArray = ["hola", "mundo"]
miArray.joined(separator:"/")  //devolvería "hola/mundo"
```

> Lo sé, parece un poco tonto separar un String en un array y volver a juntarlo para mostrarlo, pero los *tags* están almacenados de modo mejor estructurado como array, y la forma más sencilla de mostrarlos es como String 


### Añadir otra entidad (6 puntos)

Queremos que las notas puedan estar agrupadas en "libretas". Cada libreta contendrá muchas notas, pero cada nota solo puede estar en una libreta.

- Añadir la entidad Libreta, con un atributo nombre de tipo String
- Crear una relación "a muchos" de `Libreta` a `Nota` y "a uno" de `Nota` a `Libreta` (la inversa)

#### Insertar libretas en Core Data

Para simplificar será un botón "nueva libreta" en la pantalla inicial, que al pulsarlo debe mostrar un *alert* con un camp de texto con el nombre de la libreta. Tendrás que definirte el *action* correspondiente para detectar que se ha pulsado el botón. En el *action* puedes llamar al siguiente código para mostrar el *alert*:

```swift
func nuevaLibreta() {
    let alert = UIAlertController(title: "Nueva libreta",
                                  message: "Escribe el nombre para la nueva libreta",
                                  preferredStyle: .alert)
    let crear = UIAlertAction(title: "Crear", style: .default) {
        action in
        let nombre = alert.textFields![0].text!
        //AQUI FALTA GUARDAR LA LIBRETA CON CORE DATA
    }
    let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) {
        action in
    }
    alert.addAction(crear)
    alert.addAction(cancelar)
    alert.addTextField() { $0.placeholder = "Nombre"}
    self.present(alert, animated: true)
}
```

- En el código anterior falta **guardar la libreta** usando Core Data, implementa esta funcionalidad

#### Listar libretas

Antes de empezar con esto asegúrate de que las libretas se están creando correctamente en la base de datos. En el `viewWillAppear` de la pantalla de lista de notas puedes poner provisionalmente una consulta que las imprima en la consola (luego acuérdate de quitarlo)

```swift
let queryLibretas = NSFetchRequest<Libreta>(entityName:"Libreta")
//RECUERDA QUE NECESITAS EL CONTEXTO DE PERSISTENCIA. AQUI SE LLAMA "miContexto"
let libretas = try! miContexto.fetch(queryLibretas)
for libreta in libretas {
    print(libreta.nombre)
}
```

Para que el usuario pueda seleccionar la libreta en la pantalla de creación de notas vamos a usar un *picker view*, la típica "rueda" para seleccionar valores de una lista.

- Añade un componente *picker view* a la pantalla de creación de notas. Crea un *outlet* para poder acceder a él desde Swift. Dale el nombre que quieras.
- Desde el punto de vista del código, un *picker view* requiere de un *delegate* y de un *datasource* (más o menos como las tablas). Crea una nueva clase `GestorPicker` en un archivo del mismo nombre, así no llenamos de tanto código el `ViewController`

```swift
import Foundation
import UIKit
import CoreData


class GestorPicker : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var libretas = [Libreta]()
    
    //devuelve el número de columnas del picker. En nuestro caso solo 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //devuelve el número de filas del picker (== número de libretas)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.libretas.count
    }
    
    //devuelve el título de una fila determinada
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.libretas[row].nombre
    }
    
    //para cargar la lista de libretas desde Core Data
    func cargarLista() {
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Libreta>(entityName:"Libreta")
        self.libretas = try! miContexto.fetch(request)
    }
}
```

Ahora **en el `ViewController` añade una nueva propiedad **, una instancia de la clase anterior

```swift
//Esto es una propiedad del ViewController, va dentro de la clase y FUERA de los métodos
let miGestorPicker = GestorPicker()
```

y en el `viewDidLoad` del `ViewController` conectamos el *picker* con su *delegate/datasource* y cargamos la lista de libretas con Core Data

```swift
//Aquí, "picker" es el outlet que representa al "picker view"
//CAMBIALO por el nombre que le hayas dado
self.picker.delegate = self.miGestorPicker
self.picker.dataSource = self.miGestorPicker
//cargamos las libretas con Core Data
self.miGestorPicker.cargarLista()
```

Tal como está ahora la aplicación la lista de libretas debe aparecer cuando se arranca, pero si se añade una nueva libreta no aparecerá en el *picker* hasta que se pare la app y se vuelva a arrancar (que es cuando se llama a `cargarLista()`). Puedes arreglarlo haciendo dos cosas justo después de guardar la nueva libreta con core data (en la función `nuevaLibreta` de antes):

-  Añadir la nueva libreta a la lista que tiene dentro el `miGestorPicker`: 

```swift
self.miGestorPicker.libretas.append(libreta)
```

- Decirle al componente *picker view* que se repinte recargando los datos

```swift
//de nuevo, "picker" es el outlet del "picker view". Cámbialo por el tuyo
self.picker.reloadAllComponents()
```

#### Asociar una libreta a la nota actual

Falta que cuando se guarde la nota, se le asocie la libreta que aparece seleccionada en el *picker view*. Igual que asignas el "texto" y la "fecha" de la nota, **asígnale también el objeto libreta usando la relación "a uno" entre `Nota` y `Libreta`**. Para saber qué número de opción está seleccionado actualmente en un *picker* puedes usar su método `selectedRow`:

```swift
//de nuevo, "picker" es el outlet del "picker view". Cámbialo por el tuyo
let numLibreta = self.picker.selectedRow(inComponent: 0)
```

El objeto `Libreta` en esa posición será la misma posición del array `libretas` del `self.miGestorPicker`.

#### Mostrar la libreta al listar las notas

Para simplificar, esto puedes hacerlo por la consola si no quieres complicarte. En caso contrario puedes mostrarlo en la parte del texto de detalle de la celda (recuerda que era la propiedad `detailTextLabel` de la celda). Coge el valor que haya  (que tendrá también ls *tags*) y concaténale el nombre de la libreta entre paréntesis, por ejemplo.