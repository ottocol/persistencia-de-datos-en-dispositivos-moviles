## Modelo/Vista/Controlador

### Los problemas de MVC

En teoría la estructura de una aplicación iOS con MVC debería ser sencilla y "limpia", ya que cada uno de los tres componentes tiene una responsabilidad separada. 

![](img/expectativa_mvc.png)

En la práctica, la principal fuente de problemas de esta arquitectura es el *controlador*. Por un lado, el `UIViewController` está tan **unido a la vista** que acaba siendo parte de ella en lugar de un componente separado. En la realidad la arquitectura de muchas aplicaciones iOS acaba pareciéndose más a la siguiente figura que a la anterior:

![](img/realidad_mvc.png)

Al estar tan acoplado el controlador a la vista se hace casi imposible hacer *testing* del controlador en sí, sin probar la interfaz de usuario, ya que tendríamos que hacer un *mock* de todos los componentes de la vista que interactúan con el controlador.

Por otro lado es fácil "dejarse llevar" y acabar asignándole **demasiadas responsabilidades** al controlador: colocar en él lógica de negocio, hacer que sea el *datasource* o el *delegate* de las tablas que contiene,... Esto da lugar a lo que de modo irónico se conoce como *massive view controller*.

Para solucionar todos estos problemas podemos usar una arquitectura distinta, como veremos en apartados posteriores. Pero no todo son problemas en MVC tal como lo propone Apple: tiene la ventaja de estar especialmente adaptado a la filosofía de la plataforma, los *frameworks* y los APIs de iOS, y además es una arquitectura sencilla. Una alternativa sería continuar usándolo pero intentar "aligerar" el controlador en la medida de lo posible para hacer el código más mantenible. Vamos a ver cómo podríamos hacerlo.

### Controladores "ligeros"

Básicamente la idea es dejar en el controlador el mínimo de código imprescindible para coordinarse con el modelo y con la vista. Aunque todo lo que se va a comentar aquí es bastante de "sentido común de desarrollador", no está de más repasarlo.

- Trasladar la responsabilidad de *datasources* o *delegates* a clases auxiliares
- Mover la lógica de dominio al modelo


