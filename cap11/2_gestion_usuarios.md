## Autentificación y gestión de usuarios

La gran mayoría de aplicaciones tiene que gestionar datos de usuarios y autentificarlos para poder realizar ciertas operaciones. Típicamente vamos a tener que:

- Implementar un CRUD de usuarios, para poder darlos de alta, de baja y que puedan modificar sus datos de perfil.
- Implementar funcionalidades de login/logout para que el usuario se pueda autentificar en la aplicación y así tenga acceso a las funcionalidades que la requieran.

Firebase cubre los dos tipos de funcionalidades. Además no solo vamos a poder gestionar usuarios dándolos de alta en la aplicación con login y password, sino que también nos permite autentificación con credenciales externas, o *identidad federada*: el usuario puede identificarse en nuestra *app* con su login de otros sitios como Facebook, Twitter o Google, con lo que se evita tener que crearse un nuevo usuario/contraseña solo para nuestra aplicación.

### Añadir autentificación a una app de Firebase

Las funcionalidades de usuarios están en el módulo `auth`. Si usamos Cocoapods para gestionar las dependencias, tendremos que añadir la siguiente dependencia al `Podfile`

```bash
pod 'Firebase/Auth'
```

tras ello, ejecutar en la consola `pod install`.

Para poder llamar a este API en nuestro código necesitaremos un 

```swift
import Firebase
```

Podéis consultar *online* y traducida al español la [documentación de las librerías de iOS](https://firebase.google.com/docs/auth/ios/start) para gestión de usuarios y autentificación.

### Administración de usuarios

Los usuarios en Firebase tienen una serie de propiedades básicas: un *id* único, una dirección de correo electrónico, un nombre y la URL de su foto de perfil. Todos los usuarios tienen estos datos, aunque podemos simplemente ignorar alguno en nuestra *app* (por ejemplo la URL). A los objetos usuario no se les pueden añadir más propiedades, si necesitamos más datos (fecha de nacimiento, sexo, e-mail secundario,...) tendremos que almacenarlos aparte en la base de datos de Firebase.

Aunque Firebase permite que los usuarios puedan autentificarse con credenciales de Google, Facebook, Twitter, ... aquí solo veremos la autentificación con contraseña, es decir, los usuarios van a darse de alta en nuestra *app* y elegir un login (que debe ser su *email*) y un *password*. *passwors* no lo podremos consultar desde nuestra *app*, solo modificar). Para ver cómo autentificarse con identidades federadas, consultar la [documentación de Firebase](https://firebase.google.com/docs/auth/ios/start#next_steps)

Como veremos, la mayoría de métodos del API son asíncronos, ya que requieren de interacción con el servidor y hacerlos síncronos bloquearía la *app* hasta que este respondiera. Los métodos asíncronos del API tienen como último parámetro  una clausura que se ejecutará cuando el servidor complete la operación. 

La clausura a ejecutar recibe como parámetro un error en caso de haberse producido alguno, y además en algunos métodos recibe un parámetro adicional con el resultado de la operación si ha sido exitoso.

#### Dar de alta usuarios

Para **dar de alta un usuario** llamaremos al método `createUser(withEmail:,password:,completion:)`. Es un método asíncrono, su último parámetro es una clausura que se ejecutará cuando se complete en el servidor el proceso de registro. Como ya se ha dicho esta clausura recibe como parámetro el error producido, si lo hay. Si no ha habido error, además como primer parámetro se recibe un objeto de tipo `AuthDataResult` con el resultado de la operación. Dentro de este objeto el campo `user` contiene información sobre el usuario recién creado. 

Por ejemplo:

```swift
Auth.auth().createUser(withEmail: email, password: password) { 
    (result, error) in
    if let error = error {
        print("Error")
    }
    else {
        print("Dado de alta usuario con email: \(result?.user.email!)")
    }
}
```

Como es lógico, antes de poder llamar a este método tenemos que haber hecho algún formulario para que el usuario rellene sus datos, pedirle dos veces la contraseña para chequear errores, etc. Esto es tarea nuestra y de ello no se va a ocupar `createUser`. Llamaremos a este método solo cuando hayamos validado que los datos introducidos por el usuario son correctos (que el email no está vacío y tiene un formato adecuado, que los dos *passwords* del formulario coinciden, ...).

> Como crear las pantallas de alta, login, etc es un proceso tedioso, en Firebase existe un módulo denominado `FirebaseUI` que implementa la interfaz de las operaciones más comunes. Podéis consultar más información en la [documentación de Firebase](https://firebase.google.com/docs/auth/ios/firebaseui).

Nótese además que el `createUser` solo rellena los datos más básicos, para rellenar el resto de datos usaremos la funcionalidad de actualizar perfil.

#### Validar el alta de un usuario

En muchos sitios web cuando un usuario se da de alta se le envía por email un *link* para que confirme el registro. En Firebase podemos hacer esto con el método `sendEmailVerification` del usuario actual. Este método pertenece al usuario autentificado .

Para obtener el usuario autentificado actualmente en la *app* accedemos a la propiedad `Auth.auth().currentUser`. Si es `nil` no hay ningún usuario autentificado.

```swift
Auth.auth().currentUser?.sendEmailVerification { (error) in
  // ...
}
```

#### Modificar el perfil de un usuario

Para modificar los datos de un usuario, el objeto usuario correspondiente debe llamar a `createProfileChangeRequest`, hacemos los cambios y finalmente llamamos a `commitChanges(completion:)`, que es asíncrono, y al que se le pasa una clausura a ejecutar cuando los cambios se hagan efectivos en el servidor. 

```swift
let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
changeRequest?.displayName = displayName
changeRequest?.commitChanges { (error) in
  if let error = error {
     print("Error: \(error)")
  } 
  else {
     print("Perfil actualizado OK")
  }
}
```

Hay métodos individuales para actualizar el *email* y el *password*: `updateEmail` y `updatePassword`. Son métodos asíncronos, y como parámetro, además del nuevo valor, pasaremos una clausura a ejecutar cuando acabe la operación:

```swift
Auth.auth().currentUser?.updateEmail(to: email) { (error) in
  // ...
}
Auth.auth().currentUser?.updatePassword(to: password) { (error) in
  // ...
}
```

Por razones de seguridad, cuando un usuario cambia su dirección de correo electrónico, se le envía un *email* a la su dirección  para que pueda consultar el cambio. Se puede cambiar la plantilla que se usa para este email en la consola de Firebase, en el apartado: `Autenticación > Plantillas`.

En lugar de actualizar el *password* directamente, podemos enviarle al usuario el típico mensaje de *resetear password*, con un enlace en el que se hace *clic* se saltará a una página (hecha por Google) con un formulario para cambiar el *password*.  

#### Dar de baja a un usuario

Para borrar a un usuario, usamos `delete`, que de nuevo es un método asíncrono:

```swift
let user = Auth.auth().currentUser
user?.delete { error in
  if let error = error {
    print("Error")
  } else {
    print("Cuenta dada de baja")
  }
}
```

### Autentificación

Para *hacer login* en la aplicación, llamamos al método `signIn`, que como viene siendo habitual es asíncrono. Si la autentificación tiene éxito se devuelve un objeto de tipo `AuthDataResult` que contiene entre otros datos la referencia al usuario autentificado en su campo `user`.

```swift
Auth.auth().signIn(withEmail: email, password: password) { 
  (result, error) in
  if let error = error {
    print("Error")
  } else {
    print("Login de: \(result?.user.email!)")
  }
}
```

como ya hemos visto en el apartado anterior, para saber el usuario actual podemos acceder a `Auth.auth().currentUser`.

Hay que destacar que la "sesión" actual se guarda de manera persistente, así que si salimos de la aplicación y volvemos a entrar, el usuario seguirá estando activo hasta que cerremos explícitamente la sesión. Para cerrar la sesión, llamar al método `signOut`, que es síncrono:

```swift
do {
  try Auth.auth().signOut()
} catch let signOutError as NSError {
  print("Error cerrando la sesión: \(signOutError)")
}
```

Podemos detectar el *sign-in* y *sign-out* del usuario con `addStateDidChangeListener`. Le pasaremos una clausura que se ejecutará cuando se haga una de estas dos operaciones, es decir, es un *listener* del cambio de estado. Típicamente se usa para mostrar el estado actual en la interfaz de usuario, por lo que normalmente se añadirá el *listener* al mostrar la pantalla con los datos, es decir en el `viewWillAppear` del controlador de la vista:

```swift
//donde "handle" sería una propiedad del view controller
self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
  // ...
}
```

El valor de retorno del método anterior se usa para eliminar el *listener*. Habitualmente el lugar más apropiado es cuando salimos de la pantalla, en el `viewWillDisappear`) del controlador de la vista:

```swift
Auth.auth().removeStateDidChangeListener(self.handle)
``
