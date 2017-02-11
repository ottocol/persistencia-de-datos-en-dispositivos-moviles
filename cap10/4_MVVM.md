## MVVM

### MVVM vs. MVP

El patrón de diseño Model/View/ViewModel es muy similar al MVP que vimos en el apartado anterior. 

![](img/mvvm.png)


De hecho, el *ViewModel* tiene más o menos la misma funcionalidad que el *presenter*, implementar la lógica de presentación y aislarla de la tecnología concreta usada para la presentación.

¿Dónde está la diferencia entonces?. En que MVVM soluciona uno de los principales problemas que tiene MVP, el acoplamiento entre vista y *presenter*. Como estuvimos discutiendo, la *vista* y el *presenter* deben "conocerse" mutuamente, ya que la vista debe comunicarle a este las acciones del usuario, y el *presenter* enviarle a la vista los datos a mostrar. Esto hace que ambos componentes estén acoplados entre sí, ya hemos visto en el código de ejemplo de MVP que en la vista hay una referencia al *presenter* y viceversa. En MVVM no existe este acoplamiento, y lo vamos a evitar usando *bindings*, es decir, vinculación automática entre los datos del modelo y el *presenter*, de manera que cuando cambie alguno de ellos se modifique automáticamente el otro. Esto permite que el código quede mucho más "limpio", ya que no hay que actualizar el otro componente de modo explícito.

En iOS no hay ninguna tecnología estándar para vincular elementos de la vista con propiedades del modelo (aunque en OSX sí existe). Podríamos usar KVO o notificaciones para hacer la vinculación, pero la implementación sería un poco tediosa. Así que tendremos que usar alguna librería de terceros. Aquí veremos una bastante sencilla de usar llamada [Bond](https://github.com/ReactiveKit/Bond) (el nombre completo es Bond, Swift Bond :)).

> Para implementar los *bindings* podríamos usar también algún *framework* de *reactive programming*. Este paradigma de programación permite implementar la funcionalidad de manera bastante elegante. No obstante usar un *framework* de este tipo solo para implementar *bindings* probablemente sea demasiado, ya que la idea de *reactive programming* es bastante más amplia. En cualquier caso es posible que encontréis tutoriales y otros recursos de MVVM en iOS que usen *frameworks* reactivos como [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) o [RXSwift](https://github.com/ReactiveX/RxSwift). De hecho, Bond está construido sobre un *framework* de este tipo, aunque más sencillo. Y como se verá, en el ejemplo usaremos funcionalidades típicas de *programación reactiva*.

### MVVM con Bond

Vamos a verlo con un ejemplo, ya que así se entenderán mejor los conceptos. Implementaremos ahora una versión MVVM de la aplicación `UAdivino`, al estilo de la que hicimos en el apartado anterior, es decir, mostrando cada tipo de respuesta de un color distinto. La diferencia fundamental va a estar en que vincularemos de modo automático tanto el texto de la respuesta como el color para que no haga falta fijarlos de forma explícita en la vista. Esta vinculación la haremos gracias a la librería Bond.

La forma más sencilla de configurar un proyecto de Xcode con Bond es usando Cocoapods. En el README de Bond en Github están [las instrucciones](https://github.com/ReactiveKit/Bond#installation). Vamos a empezar a trabajar suponiendo que ya se ha hecho la configuración.
