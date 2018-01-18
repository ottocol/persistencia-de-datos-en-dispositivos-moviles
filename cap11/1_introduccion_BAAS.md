## Backend As A Service (BAAS)

Aunque hay algunas aplicaciones que pueden funcionar por sí solas sin necesidad de un servidor, muchas aplicaciones actuales necesitan de un *backend* para poder almacenar datos “en la nube”. Así el usuario pueda acceder a su información independientemente del dispositivo que esté usando. Otras muchas aplicaciones lo usan para que se pueda compartir información con otros usuarios.  

El problema es que desarrollar un *backend* para una aplicación móvil no es una tarea trivial, incluso si se tienen los conocimientos necesarios. Hay que escribir la aplicación en el lado del servidor, desplegarla, alojarla en algún *hosting*, hacerla escalable, …. Y además muchos desarrolladores de aplicaciones móviles no tienen las habilidades necesarias, ya que en el *backend* se usan lenguajes, tecnologías y herramientas totalmente diferentes de los usados para el desarrollo del cliente.

Esto ha hecho que surja un mercado de lo que se conoce como “Backend as a Service” (o BaaS), es decir, ofrecer como servicio “listo para usar” las funcionalidades más típicas de los *backends* para aplicaciones móviles: autentificación de usuarios, persistencia de datos “en la nube”, analíticas de tráfico, notificaciones *push* etc. Por supuesto las propias plataformas de desarrollo móvil ya ofrecen algunos de estos servicios (por ejemplo Apple ofrece persistencia “en la nube” con iCloud), pero ha surgido una serie de compañías que ofrecen estos servicios con compatibilidad multiplataforma, de modo que por ejemplo podemos acceder a los mismos datos remotos estemos en la versión iOS, en la versión Android o incluso en la versión web de la aplicación.

En la actualidad existen múltiples plataformas de terceros que ofrecen funcionalidades de Baas. Vamos a centrarnos aquí en Firebase simplemente porque es una de las más conocidas. El resto de plataformas ofrecen funcionalidades similares.

Para usar Firebase lo primero es darse de alta en [la plataforma](https://firebase.google.com/). Una vez dados de alta, podremos crear proyectos en Firebase. Un proyecto es una *app* con un conjunto de usuarios, una base de datos, un espacio para alojar archivos, etc. Esta *app* Firebase puede tener varios clientes: iOS, Android, web, ...

Para crear una aplicación iOS que actúe como cliente de nuestro proyecto de Firebase podemos seguir las instrucciones de Google: [cómo agregar Firebase a tu proyecto de iOS](https://firebase.google.com/docs/ios/setup?authuser=0). Las instrucciones están bastante detalladas y además traducidas a español. 

