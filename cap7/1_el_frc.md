
## El *fetched results controller*

Hasta ahora hemos obtenido los datos de Core Data con *fetch requests*. En principio no es complicado mostrar estos datos en una tabla, ya que como ya hemos visto, al ejecutar una *fetch request* obtenemos un array. A lo largo del curso hemos usado múltiples veces arrays como fuentes de datos para vistas de tabla. Pero hacer esto presenta una serie de dificultades:

En primer lugar, se pueden dar problemas de **rendimiento**. Si hay muchos datos, tenerlos todos en un array ocupará demasiada memoria. Una estrategia más inteligente es ir cargándolos a medida que los vamos necesitando (conforme nos vamos desplazando por la tabla), pero vamos a emplear mucho tiempo implementando esta funcionalidad, que no es trivial.

Además, hay que tener en cuenta que **los datos pueden cambiar**. Cada vez que cambie un dato tenemos que actualizar manualmente la tabla, lo que es tedioso.

La clase `FetchedResultsController` viene a solucionar todos estos problemas. Por un lado, va a ir obteniendo los datos a medida que sean necesarios, por lotes, o *batches*. Además los guardará automáticamente en una *cache* para aumentar la eficiencia. Y por otro se suscribe a los cambios en el contexto para que cuando cambie un objeto lo podamos reflejar de forma sencilla en la tabla. Trabajar con un *fetched results controller* no va a ser trivial, pero sí mucho más sencillo que si tuviéramos que implementar todas estas funcionalidades nosotros mismos.