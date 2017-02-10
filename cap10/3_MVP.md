## Model/View/Presenter

Este patrón de diseño soluciona algunos de los problemas que tiene el MVC "al estilo Apple". El nuevo componente, llamado *presenter* se encarga de la *lógica de presentación*, y debe ser independiente de la tecnología que se esté usando para la vista, que en iOS será `UIKit`. La lógica de presentación engloba todas las operaciones necesarias para formatear los datos del modelo de modo que se puedan visualizar adecuadamente. Por ejemplo es posible que el modelo nos devuelva la distancia total de una ruta, y queramos que se pueda visualizar en metros o kilómetros. La conversión de unidades sería responsabilidad del *presenter*.

![](img/mvp.png)

A primera vista el diagrama de componentes anterior parece muy similar al original de MVC, simplemente sustituyendo el *controller* por el *presenter*. No obstante, el que el *presenter* deba ser independiente de la tecnología de la vista tiene un impacto bastante importante en el código. En las aplicaciones debemos seguir usando `UIViewControllers`, ya que son una parte básica de la plataforma. Sin embargo esta clase no es totalmente independiente de la tecnología de la vista, porque está íntimamente unida a ella. De hecho, esto era uno de los problemas que teníamos en el MVC "estilo Apple". Por eso, **en MVP consideraremos al *view controller* como parte de la vista**. Es decir, el *presenter* de ningún modo es el antiguo *controller* bajo otro nombre, sino algo totalmente distinto.

