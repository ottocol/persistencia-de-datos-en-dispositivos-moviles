import Foundation

class Alumno : NSObject, NSCoding {
    var nombre : String?
    var varon : Bool = false
    var fechaNacimiento: Date?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(nombre, forKey:"nombre")
        aCoder.encode(varon, forKey:"varon")
        aCoder.encode(fechaNacimiento, forKey:"fechaNacimiento")
    }
    
    required init?(coder aCoder : NSCoder) {
        self.nombre = aCoder.decodeObject(forKey: "nombre") as? String
        self.varon = aCoder.decodeBool(forKey: "varon")
        self.fechaNacimiento = aCoder.decodeObject(forKey: "fechaNacimiento") as? Date
    }
    
    init(nombre elNombre: String, esVaron varon : Bool,
         nacido fechaNac: Date) {
        self.nombre = elNombre
        self.varon = varon
        self.fechaNacimiento = fechaNac
    }
    
}

var a = Alumno(nombre: "Pepe", esVaron: true, nacido: Date())

let tmpDir = FileManager.default.temporaryDirectory
let archivo = tmpDir.appendingPathComponent("datos.dat")
NSKeyedArchiver.archiveRootObject(a, toFile: archivo.path)

if let aLeido = NSKeyedUnarchiver.unarchiveObject(withFile: archivo.path) as? Alumno {
  print(aLeido.nombre)
  print(aLeido.fechaNacimiento)
  print(aLeido.varon)
}

class Grupo : NSObject, NSCoding  {
    var nombre : String?
    var miembros : [Alumno] = []
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(nombre, forKey: "nombre")
        aCoder.encode(miembros, forKey: "miembros")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.nombre = aDecoder.decodeObject(forKey: "nombre") as? String
        self.miembros = aDecoder.decodeObject(forKey: "miembros") as! [Alumno]
    }
    init(nombre elNombre: String, miembros losMiembros: [Alumno]) {
        self.nombre = elNombre
        self.miembros = losMiembros
    }
}

let a2 = Alumno(nombre: "Eva", esVaron: false, nacido:Date())
var grupo = Grupo(nombre:"primero A", miembros: [a,a2])
let archivoGrupo = tmpDir.appendingPathComponent("grupo.dat")
NSKeyedArchiver.archiveRootObject(grupo, toFile: archivoGrupo.path)

if let grupoLeido = NSKeyedUnarchiver.unarchiveObject(withFile: archivoGrupo.path) as? Grupo {
    for alumno in grupoLeido.miembros {
        print(alumno.nombre!)
    }
}
