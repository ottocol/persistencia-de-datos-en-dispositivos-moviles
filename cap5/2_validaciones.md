## Validación de datos

Como ya vimos en la sesión anterior, cuando definimos el modelo de datos, para cada entidad podemos especificar una serie de *reglas de validación*, que varían según el tipo de datos: por ejemplo para cadenas podemos indicar una longitud mínima y máxima o una expresión regular, para fechas un rango de fechas válidas, para enteros también un rango, etc.

Eso no quiere decir que no podamos tener un objeto gestionado por Core Data con valores inválidos, ya que de lo único que se asegura el *framework* es que un objeto no válido no se puede guardar en el almacenamiento persistente. Es decir, los errores se disparan al hacer `save` del contexto.