//
//  DataModelParser+SwiftCode.swift
//
//
//  Created by Javier Segura Perez on 28/1/24.
//

import Foundation

class SwiftModelOutput : ModelOutputDelegate
{
    var namespace:String? = nil
    
    var fileContent:String = ""
    var filename:String = ""
    
    var currentParentClassName:String?
    var currentClassName:String = ""
    var currentClassEntityName:String = ""
    
    var primitiveProperties:[String] = []
    var relationships:[String] = []
    //    var relationships2:[String] = []
    
    var modelContent:String = "#import Foundation\nimport CoreData\n"
    
    func setNamespace(parser:DataModelParser, namespace: String?) {
        self.namespace = namespace
    }
    
    var outputPath:String
    var objcSupport = false
    
    init( outputPath:String, objcSupport:Bool = false ) {
        self.outputPath = outputPath
        self.objcSupport = objcSupport
    }
    
    func openModelEntity(parser:DataModelParser, filename:String, classname:String, parentName:String?)
    {
        self.filename = "/\(filename).swift"
        let cn = classname
        currentClassEntityName = cn;
        currentClassName = classname;
        
        relationships = []
        //        relationships2 = []
        primitiveProperties = []
        
        currentParentClassName = parentName
        
        fileContent = """
        //
        // Generated class \(cn) by MIOCoreDataBuildModelPlugin
        //
        import Foundation
        import CoreData
        
        @objc(\(self.currentClassName))
        public class \(classname) : \(parentName ?? "NSManagedObject") {}
        
        // MARK: Generated attributes
        extension \(cn)
        {
        
        """
    }
    
    func appendAttribute(parser:DataModelParser, name:String, type:String, optional:Bool, defaultValue:String?, usesScalarValueType:Bool)
    {
        let t:String
        let cast_t:String
        
        switch type {
            
        case "Boolean":
            t = usesScalarValueType == false ? "NSNumber?" : "Bool"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Bool"
            
        case "Integer":
            t = usesScalarValueType == false ? "NSNumber?" : "Int"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Int"
            
        case "Integer 16":
            t = usesScalarValueType == false ? "NSNumber?" : "Int16"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Int16"
            
        case "Integer 8":
            t = usesScalarValueType == false ? "NSNumber?" : "Int8"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Int8"
            
        case "Integer 32":
            t = usesScalarValueType == false ? "NSNumber?" : "Int32"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Int32"
            
        case "Integer 64":
            t = usesScalarValueType == false ? "NSNumber?" : "Int64"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Int64"
            
        case "Float":
            t = usesScalarValueType == false ? "NSNumber?" : "Float"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Float"
            
        case "Double":
            t = usesScalarValueType == false ? "NSNumber?" : "Double"
            cast_t = usesScalarValueType == false ? "as? NSNumber" : "as! Double"
            
        case "Decimal":
            t = "NSDecimalNumber?"
            cast_t = "as? NSDecimalNumber"
            
            
        case "Transformable":
            t = optional ? "Any?" : "Any"
            cast_t = optional ? "" : "as! Any"
            
        default:
            t = optional ? "\(type)?" : type
            cast_t = optional ? "as? \(type)" : "as! \(type)"
        }
        
        // Setter and Getter of property value
        if objcSupport {
            fileContent += "    @NSManaged public var \(name):\(t)\n"
        }
        else {
            fileContent += "    public var \(name):\(t) { get { value(forKey: \"\(name)\") \(cast_t) } set { setValue(newValue, forKey: \"\(name)\") } }\n"
            
            // Setter and Getter of property primitive value (raw)
            let first = String(name.prefix(1))
            let cname = first.uppercased() + String(name.dropFirst())
            primitiveProperties.append("    public var primitive\(cname):\(t) { get { primitiveValue(forKey: \"primitive\(cname)\") \(cast_t) } set { setPrimitiveValue(newValue, forKey: \"primitive\(cname)\") } }\n")
        }
    }
    
    func appendRelationship(parser:DataModelParser, name:String, destinationEntity:String, toMany:String, optional:Bool)
    {
        if (toMany == "NO") {
            if objcSupport {
                fileContent += "    @NSManaged public var \(name):\(destinationEntity)\(optional ? "?" : "")\n"
            } 
            else {
                fileContent += "    public var \(name):\(destinationEntity)\(optional ? "?" : "") { get { value(forKey: \"\(name)\") as\(optional ? "?" : "!")  \(destinationEntity) } set { setValue(newValue, forKey: \"\(name)\") }}\n"
            }
        }
        else {
            let first = String(name.prefix(1))
            let cname = first.uppercased() + String(name.dropFirst())
            
            var content = ""
            
            if objcSupport {
                fileContent += "    @NSManaged public var \(name):Set<\(destinationEntity)>?\n"
                
                content += "// MARK: Generated accessors for \(name)\n"
                content += "extension \(self.currentClassName)\n"
                content += "{\n"
                content += "    @objc(add\(cname)Object:)\n"
                content += "    @NSManaged public func add\(cname)Object(_ value: \(destinationEntity))\n"
                content += "\n"
                content += "    @objc(remove\(cname)Object:)\n"
                content += "    @NSManaged public func remove\(cname)Object(_ value: \(destinationEntity))\n"
                content += "\n"
                content += "    @objc(add\(cname):)\n"
                content += "    @NSManaged public func add\(cname)(_ values: Set<\(destinationEntity)>)\n"
                content += "\n"
                content += "    @objc(remove\(cname):)\n"
                content += "    @NSManaged public func remove\(cname)(_ values: Set<\(destinationEntity)>)\n"
                content += "}\n"
            }
            else {
                fileContent += "    public var \(name):Set<\(destinationEntity)>? { get { value(forKey: \"\(name)\") as? Set<\(destinationEntity)> } set { setValue(newValue, forKey: \"\(name)\") }}\n"
                
                content += "// MARK: Generated accessors for \(name)\n"
                content += "extension \(self.currentClassName)\n"
                content += "{\n"
                content += "    @objc(add\(cname)Object:)\n"
                content += "    public func add\(cname)Object(_ value: \(destinationEntity)) { _addObject(value, forKey: \"\(name)\") }\n"
                content += "\n"
                content += "    @objc(remove\(cname)Object:)\n"
                content += "    public func remove\(cname)Object(_ value: \(destinationEntity)) { _removeObject(value, forKey: \"\(name)\") }\n"
                content += "\n"
                content += "    @objc(add\(cname):)\n"
                content += "    public func add\(cname)(_ values: Set<\(destinationEntity)>) { for obj in values { _addObject(obj, forKey: \"\(name)\") } }\n"
                content += "\n"
                content += "    @objc(remove\(cname):)\n"
                content += "    public func remove\(cname)(_ values: Set<\(destinationEntity)>) { for obj in values { _removeObject(obj, forKey: \"\(name)\") } }\n"
                content += "}\n"
            }
                                                
            relationships.append(content)
        }
    }
    
    func closeModelEntity( parser:DataModelParser ) throws
    {
        fileContent += "}\n"
        
        for rel in relationships {
            fileContent += "\n" + rel
        }
        
        let output_url = URL( fileURLWithPath: outputPath + "/" + filename )
        try fileContent.write( to: output_url, atomically: false, encoding: .utf8 )

        
//        for rel in relationships2 {
//            fileContent2 += "\n" + rel
//        }
        
        // Only MIOCoreData for Linux
//        fileContent2 += "\n"
//        fileContent2 += "// MARK: Generated accessors for primitivve values\n"
//        fileContent2 += "extension \(self.currentClassName)\n"
//        fileContent2 += "{\n"
//        for primitiveProperty in primitiveProperties {
//            fileContent2 += primitiveProperty
//        }
//        fileContent2 += "}\n"
                
//        fileContent += "#endif\n"
//        let modelPath = command.modelPath
//        let path = modelPath + filename
        //Write to disc
//        WriteTextFile(content:fileContent, path:path)

//        fileContent2 += "#endif\n"
//        let path2 = modelPath + filename2
//        //Write to disc
//        WriteTextFile(content:fileContent2, path:path2)

        
//        let fp = modelPath + "/" + self.currentClassName + "+CoreDataClass.swift"
//        if (FileManager.default.fileExists(atPath:fp) == false) {
//            // Create Subclass in case that is not already create
//            var content = ""
//            content += "//\n"
//            content += "// Generated class \(self.currentClassName)\n"
//            content += "//\n"
//            content += "import Foundation\n"
//            content += "#if APPLE_CORE_DATA\n"
//            content += "import CoreData\n"
//            content += "#else\n"
//            content += "import MIOCoreData\n"
//            content += "#endif\n"
//            content += "\n"
//            content += "@objc(\(self.currentClassName))\n"
//            content += "public class \(self.currentClassName) : \(currentParentClassName ?? "NSManagedObject")\n"
//            content += "{\n"
//            content += "\n}\n"
//
//            WriteTextFile(content: content, path: fp)
//        }
        
//        modelContent += "\n\t\t_MIOCoreRegisterClass(type: " + self.currentClassName + ".self, forKey: \"" + self.currentClassName + "\")"
    }
    
    func writeModelFile(parser:DataModelParser) throws
    {
//        let modelPath = command.modelPath
//
//        modelContent += "\n\t}\n}\n"
//        modelContent += "#endif\n"
//
//        let path = modelPath + "/_CoreDataClasses.swift"
//        WriteTextFile(content:modelContent, path:path)
    }
}

