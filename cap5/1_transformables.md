## Más tipos de datos en Core Data

Hasta el momento hemos visto que en una entidad de Core Data puede haber atributos de diversos tipos: enteros, reales, cadenas y fechas. 

¿Y si queremos almacenar un atributo de otro tipo, por ejemplo un array, un diccionario o una instancia de cualquier otra clase no contemplada en los casos anteriores?. Si es una clase propia siempre podemos convertirla en otra entidad, pero puede haber casos en los que no tenga mucho sentido complicar el modelo de este modo. Para estos casos tenemos el tipo *transformable*, en el que Core Data transformará a binario (`NSData`) el atributo para hacerlo persistente. Y a la inversa, cuando lo lea del almacenamiento lo decodificará de binario al tipo de datos correspondiente. 

Con los atributos transformables tenemos dos casos posibles: el "fácil", en el que no tenemos que escribir código ya que Core Data puede realizar la transformación automáticamente, y el más complejo, en el que tendremos que implementar nosotros mismos la transformación. Todo depende de si el dato a almacenar implementa el protocolo `NSCoding`. Recordemos de la primera sesión que las clases que implementan en otro protocolo son *archivables* o *serializables*. Así que Core Data no hace directamente la transformación sino que recurre al mecanismo estándar en iOS para archivar/desarchivar objetos.

Por ejemplo supongamos que en una entidad de Core Data quisiéramos almacenar un array de String. No podemos crear un atributo de Core Data de este tipo directamente, pero afortunadamente los arrays implementan el protocolo `NSCoding`, así que la transformación va a ser automática. Seguiríamos estos pasos

- En la entidad, definir el tipo del atributo como `Transformable`.
- Generar la clase de la entidad con Xcode de manera manual (con `Editor>Create NSManagedObject subclass...`)
- Opcionalmente, modificar el archivo fuente generado por Xcode, que habrá puesto la propiedad como `NSObject` y cambiarla por el tipo correspondiente. En este caso `[String]` De este modo nos ahorraremos el *cast* hacia y desde `NSObject`. La contrapartida es que si volvemos a generar la clase nos tocará volver a editar el archivo.

Ya no hay que hacer nada más. Nosotros trataremos con la propiedad como un array de `String` y automáticamente se hará la transformación hacia y desde binario, que es como se almacenan los datos.

En caso de que el tipo de datos del atributo no sea conforme al protocolo `NSCoding` tendremos que escribir una clase propia que haga la transformación a y desde binario. En Cocoa esto se hace implementando una clase que herede de `NSValueTransformer`. Para ver un ejemplo concreto podéis consultar [este tutorial](http://bluelemonbits.com/index.php/2016/02/07/using-nsvaluetransformers-value-transformer-swift-2-0/).

