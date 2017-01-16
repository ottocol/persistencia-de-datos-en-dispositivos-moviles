## Migraciones *ligeras*

Se conocen como migraciones *ligeras* aquellas en las que Core Data se puede encargar de manera prácticamente automática de migrar los datos a la nueva versión del modelo. Típicamente comprenden estas operaciones:

- Añadir o eliminar un atributo o relación
- Convertir en opcional un atributo requerido
- Convertir en requerido un atributo opcional, siempre que se dé un valor por defecto
- Añadir o eliminar una entidad
- Renombrar un atributo o relación
- Renombrar una entidad

Hasta iOS9 inclusive, el *stack* de Core Data que creaba Xcode marcando la casilla `Use Core Data` al crear un proyecto no tenía activadas las migraciones *ligeras* por defecto. Así, cualquier cambio en el modelo llevaba a que la aplicación dejara de funcionar, generando un error, y tuviéramos que borrar la base de datos manualmente para que volviera a hacerlo. Para averiguar cómo activar las migraciones *ligeras* en iOS<=9 se puede consultar el último punto de los apuntes de esta sesión.

A partir de iOS10, si se usa la clase `NSPersistentContainer` para inicializar el *stack* de Core Data no hay que hacer nada especial para activar las migraciones *ligeras*. ya que vienen activadas por defecto. Recordemos que el código de la plantilla de Xcode usa esta clase, así que normalmente no tendremos que hacer nada.

Esto quiere decir que podemos hacer cualquier modificación de las listadas antes sin más, aunque se recomienda no modificar el modelo de datos directamente sino crear una nueva versión cada vez que cambiemos algo, como se explica en el apartado anterior.

Para algunos tipos de modificación la migración automática que hace por defecto Core Data es apropiada en la mayoría de casos, pero en otros tendremos que "ayudarle" algo, aunque siempre de modo sencillo.

Por ejemplo, en caso de *añadir un atributo* a una entidad existente, si especificamos un valor por defecto, Core Data lo fijará también para los datos que ya existían, lo que es generalmente la mejor solución.

Sin embargo, al *renombrar un atributo o entidad* Core Data no detecta automáticamente que es un renombrado sino que lo interpreta por defecto como una eliminación del antiguo y la creación del nuevo, de modo que los antiguos valores se perderán. Esto tiene sentido si pensamos que Core Data solo tiene acceso al estado actual del modelo, y no al proceso de edición en sí. Para indicarle a Core Data que no es un nuevo atributo sino el antiguo renombrado, vamos al panel de la derecha, y habiendo pulsado el tercero de los iconos (``Data Model Inspector), en el cuadro de texto llamado `Renaming ID` tecleamos el nombre antiguo. Si hacemos esto, al migrar los datos se renombrará la columna de la tabla en lugar de crear una.

![](img/renaming%20id.png)

> En todos los lugares donde antes se hiciera referencia al atributo con el nombre antiguo habrá que cambiar  el código para que reflejen el nuevo nombre. Por desgracia Xcode no nos va a ayudar en esta tarea.

La configuración que hemos hecho en el editor del modelo indicando cuál era el nombre antiguo es lo que en Core Data se llama un *mapping model*, es decir una asociación de elementos que permite pasar del modelo antiguo al nuevo. Veremos otras formas de especificar *mapping models*, bien sea gráficamente o por código.

