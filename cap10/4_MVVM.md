## MVVM

El patrón de diseño Model/View/ViewModel es muy similar al MVP que vimos en el apartado anterior. El *ViewModel* de hecho tiene más o menos la misma funcionalidad que el *presenter*.

¿Dónde está la diferencia entonces?. En que MVVM soluciona uno de los principales problemas que tiene MVP, el acoplamiento entre vista y *presenter*. Como estuvimos discutiendo, la *vista* y el *presenter* deben "conocerse" mutuamente, ya que la vista debe comunicarle a este las acciones del usuario, y el *presenter* enviarle a la vista los datos a mostrar. Esto hace que ambos componentes estén acoplados entre sí, ya hemos visto en el código de ejemplo de MVP que en la vista hay una referencia al *presenter* y viceversa. En MVVM no existe este acoplamiento, y lo vamos a evitar usando *bindings*, es decir, vinculación automática entre los datos del modelo y el *presenter*, de manera que cuando cambie alguno de ellos se modifique automáticamente el otro. Esto permite que el código quede mucho más "limpio", ya que no hay que actualizar el otro componente de modo explícito.

