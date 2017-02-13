## Ejercicios de arquitecturas iOS

Tenemos la aplicación para consultar el tiempo que ya usamos en el módulo de *tecnologías de desarrollo* y queremos cambiarla para que en lugar de usar MVC use MVVM.

> Haz un `build` del proyecto antes de empezar a trabajar con él, para que se compile la librería Bond y las otras dependencias

### Carpetas para los fuentes

Lo primero será crear las "carpetas" necesarias para los fuentes (o *groups* como se llaman en Xcode)

- Crea un *group* llamado `Vista` (`File > New group...`) y mueve a él la clase `ViewController`, ya que en MVVM el `ViewController` es parte de la vista.
- Crear otro *group* llamado `ViewModel` y en él crear un archivo `TiempoViewModel` con una clase del mismo nombre vacía por el momento

### Ensamblaje de vista, modelo y viewmodel

En la clase de la vista (el `ViewController`) añadir una propiedad que represente al viewmodel

```swift
let viewModel = TiempoViewModel()
```

En el `TiempoViewModel` añadir una propiedad que represente al modelo

```swift
let modelo = TiempoModelo()
```

### Mostrar la descripción del tiempo

En este apartado conseguiremos que al pulsar en el botón "consultar tiempo" la descripción en modo texto (p.ej. "sol") aparezca en la pantalla del dispositivo.

En el `TiempoViewModel`

- Añade un `import Bond`
- Crear un `observable` de tipo `String` llamado `estado`, con valor inicial la cadena vacía (mira la sintaxis en transparencias/apuntes)
- Crea un método `consultarTiempo` que admita como parámetro un `String` con el nombre de la localidad a consultar

```swift
func consultarTiempo(de localidad : String) {
  //AQUI
  1. LLama a consultarTiempo del modelo. Pásale la localidad y como segundo parámetro una clausura a la que el modelo llamará cuando el servidor devuelva el estado del tiempo. Esta clausura recibe dos parámetros, el estado del tiempo como una cadena, y otra cadena con la url del icono que lo representa
  2. Dentro de esa clausura actualiza el observable estado con el valor de "descripcion"
  //más tarde nos ocuparemos del icono 
}
```



* Ahora de nuevo en la vista

- en el método consultarTiempoPulsado sustituir la llamada al modelo por

self.viewModel.consultarTiempo(localidad: loc)

- en el `viewDidLoad()` vincular la propiedad `estado` del `viewModel` al texto de la etiqueta `estadoLabel`


Haz lo mismo para el icono del tiempo

.filter {
            icono in
            return icono != ""
          }
          .map {
            icono in
            let urlIcono = URL(string:icono)!
            let datosIcono = try! Data(contentsOf:urlIcono)
            let imgIcono = UIImage(data: datosIcono)
            return imgIcono!
        }



