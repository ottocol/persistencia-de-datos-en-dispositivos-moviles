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


### Administración de usuarios

Los usuarios en Firebase tienen una serie de propiedades básicas: un *id* único, una dirección de correo electrónico, un nombre y la URL de su foto de perfil. Todos los usuarios tienen estos datos, aunque podemos simplemente ignorar alguno en nuestra *app* (por ejemplo la URL). A los objetos usuario no se les pueden añadir más propiedades, si necesitamos más datos (fecha de nacimiento, sexo, e-mail secundario,...) tendremos que almacenarlos aparte en la base de datos de Firebase.

Aunque Firebase permite que los usuarios puedan autentificarse con credenciales de Google, Facebook, Twitter, ... aquí solo veremos la autentificación con contraseña, es decir, los usuarios van a darse de alta en nuestra *app* y elegir un login (que debe ser su *email*) y un *password*. *passwors* no lo podremos consultar desde nuestra *app*, solo modificar). Para ver cómo autentificarse con identidades federadas, consultar la [documentación de Firebase](https://firebase.google.com/docs/auth/ios/start#next_steps)


#### Dar de alta usuarios

Para **dar de alta un usuario** llamaremos al método `createUser(withEmail:,password:,completion:)`. Es un método asíncrono, su último parámetro es una clausura que se ejecutará cuando se complete en el servidor el proceso de registro. Por ejemplo:



Como es lógico, antes de poder llamar a este método tenemos que haber hecho algún formulario para que el usuario rellene sus datos, pedirle dos veces la contraseña para chequear errores, etc. Llamaremos al método `createUser` solo cuando hayamos validado que los datos son correctos.

> Como crear las pantallas de alta, login, etc es un proceso tedioso, en Firebase existe un módulo denominado `FirebaseUI` que implementa la interfaz de las operaciones más comunes. Podéis consultar más información en la [documentación de Firebase](https://firebase.google.com/docs/auth/ios/firebaseui).

Nótese además que el `createUser` solo rellena los datos más básicos, para rellenar el resto de datos usaremos la funcionalidad de actualizar perfil

#### Modificar el perfil de un usuario

#### Dar de baja

### Autentificación

