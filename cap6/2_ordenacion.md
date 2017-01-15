## Ordenación de los resultados

Hasta el momento hemos obtenido los resultados en el orden en que nos los da Core Data, que salvo para las relaciones ordenadas no asegura ningún orden específico. Podemos especificar diversos criterios de ordenación usando la clase `NSSortDescriptor`. Al igual que `NSPredicate`, esta clase no es propia de Core Data sino de oundation, así que se puede usar también para ordenar colecciones en memoria.

```swift
let credSort = NSSortDescriptor(key:"creditos", ascending:false)
let loginSort = NSSortDescriptor(key:"login" ascending:true)
miFetchRequest.sortDescriptors = [credSort, loginSort]
```

Como se ve, cada `NSSortDescriptor` referencia la propiedad por la que ordenar y si debe o no ser un orden ascendente. Para usar el *sort descriptor*, asignamos un array de ellos a la propiedad `sortDescriptors` de la *fetch request*.  El orden en el array especificará la prioridad en la ordenación. En este caso se ordenará por orden descendente de créditos y para los que tengan los mismos créditos por orden ascendente de *login*. 