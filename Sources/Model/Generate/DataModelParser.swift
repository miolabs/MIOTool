//
//  DataModelParser.swift
//
//
//  Created by Javier Segura Perez on 28/1/24.
//

import Foundation

protocol ModelOutputDelegate
{
    func setNamespace(parser:DataModelParser, namespace:String?)
    func openModelEntity(parser:DataModelParser, filename:String, classname:String, parentName:String?)
    func closeModelEntity(parser:DataModelParser) throws
    func appendAttribute(parser:DataModelParser, name:String, type:String, optional:Bool, defaultValue:String?, usesScalarValueType:Bool)
    func appendRelationship(parser:DataModelParser, name:String, destinationEntity:String, toMany:String, optional:Bool)
    func writeModelFile(parser:DataModelParser) throws
}

class DataModelParser:NSObject, XMLParserDelegate
{
//    public var outputPath:String
    
    var modelFilePath:String
    var namespace:String?
    
    var outputDelegate:ModelOutputDelegate? = nil
    
    var customEntity:String?
    var customEntityFound = false
                
    init(modelFilePath: String, namespace:String? = nil) {
        
        self.modelFilePath = modelFilePath
//        self.outputPath = outputPath
        self.namespace = namespace
        
//        switch type {
//        case .javascript:   outputDelegate = JavascriptModelOutput()
//        case .swift:        outputDelegate = SwiftModelOutput()
//        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        outputDelegate?.setNamespace(parser: self, namespace: namespace)
    }
    
    static func parsePath(_ path:String) -> String {
        var newPath = path
        
        if newPath.hasPrefix("\"") {
            newPath = String(newPath.dropFirst().dropLast().trimmingCharacters(in: .whitespaces))
        }
        
//        if newPath.hasPrefix("/") == false {
//            newPath = CurrentPath() + "/" + newPath
//        }
        
        return (newPath as NSString).standardizingPath
    }
        
    func execute() throws {
                        
        let parser = XMLParser(contentsOf:URL(fileURLWithPath: modelFilePath))
    
        if parser != nil {
            parser!.delegate = self
            parser!.parse()
        }
        
        if let error = parser?.parserError {
            throw error
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "entity" {
            
            let filename = attributeDict["name"]
            let classname = attributeDict["representedClassName"]
            let parentName = attributeDict["parentEntity"]
            
            if customEntity != nil {
                if customEntity! != classname { return }
                customEntityFound = true
                outputDelegate?.openModelEntity(parser:self, filename:filename!, classname:classname!, parentName:parentName)
            }
            else {
                customEntityFound = true
                outputDelegate?.openModelEntity(parser:self, filename:filename!, classname:classname!, parentName:parentName)
            }
        }
        else if elementName == "attribute" {
            
            if customEntityFound == false { return }
            
            let name = attributeDict["name"]
            let type = attributeDict["attributeType"]
            let optional = attributeDict["optional"] ?? "NO"
            let defaultValue = attributeDict["defaultValueString"]
            let usesScalarValueType = attributeDict["usesScalarValueType"] ?? "YES"
            
            outputDelegate?.appendAttribute(parser:self, name:name!, type:type!, optional:(optional == "YES"), defaultValue: defaultValue, usesScalarValueType: (usesScalarValueType == "YES"))
        }
        else if elementName == "relationship" {
            
            if customEntityFound == false { return }
            
            let name = attributeDict["name"];
            let optional = attributeDict["optional"] ?? "NO";
            let destinationEntity = attributeDict["destinationEntity"];
            let toMany = attributeDict["toMany"] ?? "NO"
            
            if destinationEntity != nil {
                outputDelegate?.appendRelationship(parser:self, name:name!, destinationEntity:destinationEntity!, toMany:toMany, optional:(optional == "YES"))
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
        if elementName == "entity" {
            if customEntityFound == false { return }
            customEntityFound = false
            do {
                try outputDelegate?.closeModelEntity(parser:self)
            }
            catch {
                parser.abortParsing()
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
    
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
//        do {
//            if customEntity == nil { try outputDelegate?.writeModelFile(parser:self) }
//        }
//        catch {
//            parser.abortParsing()
//        }
    }
    
}


