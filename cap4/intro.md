# Introducción

En este tema veremos la parte central de Core Data: el modelo de datos. El modelo de datos es el grafo de objetos (entidades) que implementan nuestra lógica de negocio y que queremos que sean persistentes. Ya hemos visto cómo definir estas entidades a nivel básico. 

Veremos cómo personalizar las clases de las entidades, lo que simplificará nuestro código y además nos permitirá añadir métodos propios a los objetos persistentes. Veremos también cómo relacionar las entidades entre sí, ya que como hemos dicho formarán un grafo de objetos.

Una vez definido el modelo veremos que con Core Data podemos hacer operaciones de tipo CRUD (Create/Read/Update/Delete) de modo sencillo, con una entidad y con las entidades relacionadas. Finalmente veremos un par de funcionalidades que implementa Core Data y que van a ser muy útiles en nuestras aplicaciones: la validación de datos y la posibilidad de deshacer/rehacer operaciones.