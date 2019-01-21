## Ejercicios de Firebase

En las plantillas de la sesión hay un proyecto Xcode con las librerías de Firebase ya instaladas y configuradas. El proyecto está vinculado con una aplicación ya dada de alta en el servidor de Firebase.

> IMPORTANTE: para trabajar con el proyecto, **abrir el `.xcworkspace`**, NO el `.xcodeproj` que abrimos habitualmente. Al abrir el *workspace* veréis dos proyectos, uno con la *app* en sí, llamado `ChatFirebase` y otro con las librerías auxiliares llamado `pods`. Tras abrir el *workspace* lo primero que deberíais hacer es `Product > Build`.

El objetivo es desarrollar un pequeño chat con la *realtime database*. La plantilla ya tiene la interfaz hecha y hay que añadirle el código de Firebase.


### Login/logout (3 puntos)

#### Pantalla inicial:

En la pantalla inicial de la *app* hay un formulario para hacer login. **Añade el código necesario para que cuando se pulse sobre el botón "Entrar" se haga login en Firebase**. 

#### Segunda pantalla

El botón "Entrar" está conectado mediante un *segue* con la segunda pantalla, que es donde se verán los mensajes del chat. En el *outlet* `usuarioLabel` debería aparecer el login del usuario que se ha autentificado.

**Añade el código necesario para mostrar el email del usuario actual de Firebase** en el `usuarioLabel`. Puedes hacerlo en el método `viewWillAppear` del `ChatViewController`. 

Finalmente, **añade el código necesario para que al pulsar sobre `Salir`** se haga *logout* en Firebase.  


### Mensajes del chat (5 puntos)

Usaremos la siguiente estructura para almacenar los mensajes del chat:

```json
{
  "mensajes": {
    "1jdakdueidas" : {
        "texto":"hola qué tal",
        "usuario":"pepe@ua.es"
    },
    "uiusd_ur48850_d" : {
        "texto":"bien,y tú?",
        "usuario":"pepa@ua.es"
    }
  }
}
```

donde los identificadores de mensaje deberían ser generados automáticamente por la base de datos con `childByAutoId()`

> Llevad mucho cuidado, ya que con vuestro usuario tenéis permiso total para escribir en la base de datos, por lo que por error podríais borrar los mensajes enviados por los demás.

Para que funcione el chat hay que implementar dos funcionalidades:

- Que cuando se pulse sobre "Enviar" se guarde el mensaje en la BD. Usando el API de la base de datos habrá que:
    + Obtener la referencia al nodo "mensajes"
    + Generar la referencia a un nuevo nodo id hijo de la referencia anterior con `childByAutoId()` 
    + Fijar el valor de este nuevo nodo con `setValue()` a un diccionario Swift con las claves "texto" y "usuario" y que contenga el texto del mensaje y el email del usuario actual de Firebase.

> Con el HTML que se incluye en las plantillas podéis ver el estado actual de la BD y podéis comprobar si se ha insertado correctamente vuestro mensaje 

- Que cuando alguien envía un mensaje al chat este aparezca en la tabla
    - Recibir el mensaje: en el `viewWillAppear` del `ChatViewController` añadir un *listener* para que escuche el evento `.childAdded` sobre el nodo "mensajes"

Ten en cuenta que el código que recibe el evento recibe un parámetro `snapshot` con los nuevos valores en el campo `value`. En nuestro caso será un diccionario con el texto y el usuario. Podemos hacer el *cast* a un diccionario con claves y valores `String` para poder usarlo en el código, algo como:

```swift
if let valor = snapshot.value, let v = valor as? [String:String] {
   //Aquí ya podríamos acceder a los valores con v["texto"] y v["usuario"]
}
```

    - Cuando se reciba el evento, mostrar el mensaje en la tabla. Con el texto del mensaje y el email del usuario construir un `struct` de tipo `Mensaje` y añadirlo al array `self.mensajes` del `ChatViewController`. Para que aparezca visualmente en la tabla tienes además que añadir una fila en la posición correspondiente:

```swift
let indexPath = IndexPath(row:self.mensajes.count-1,section:0)
self.miTabla.insertRows(at: [indexPath], 
                     with: UITableViewRowAnimation.bottom)
```

