# Persistencia básica en iOS

En este tema veremos APIs básicos para poder almacenar estructuras de datos relativamente sencillas. Si la cantidad de información que necesitamos almacenar no es demasiado amplia ni tampoco tenemos que hacer consultas o búsquedas podemos usar APIs de iOS bastante simples (al menos comparados con los que se usan para acceder a bases de datos).

El caso más típico es cuando necesitamos almacenar un conjunto de pares "clave/valor", para los que podemos usar *property lists* o bien el sistema de preferencias de iOS. Este es el mecanismo habitual para guardar las preferencias de una aplicación (colores, tipos de letra, datos básicos del usuario,...).

Si necesitamos almacenar objetos de clases propias cualesquiera podemos *archivarlas*, que sería lo que en otros lenguajes se denomina *serializar*. Acabaremos el capítulo viendo cómo se pueden archivar objetos en iOS.