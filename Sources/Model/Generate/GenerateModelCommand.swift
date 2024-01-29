//
//  GenerateModelCommand.swift
//
//
//  Created by Javier Segura Perez on 28/1/24.
//

import Foundation
import ArgumentParser

enum MIOCoreDataToolError : Error
{
    case couldNotOpenFileVersion
    case couldNotParseVersionPlist
    case versionPlistHasNoCurrentVersionKey
}

enum CodeType : EnumerableFlag
{
    case swift
    case typeScript
}

enum CodeGenerator : EnumerableFlag
{
    case objc
    case noObjc
}


struct GenerateModelCommand: ParsableCommand
{
    static var configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate model classes"
    )

    @Argument(help: "the datamodel folder.")
    var modeFilePath:String
    
    @Option(name: .shortAndLong, help: "The path of generate files.")
    var outputFolderPath: String
    
    @Flag
    var codeType:CodeType = .swift

    @Flag
    var objcSupport:Bool = false

    
    mutating func run() throws {
                
        let version_url = URL( fileURLWithPath: "\(modeFilePath)/.xccurrentversion" )
                
        guard let version_data = try? Data( contentsOf: version_url ) else {
            throw MIOCoreDataToolError.couldNotOpenFileVersion
        }
        
        guard let plist = try? PropertyListSerialization.propertyList( from: version_data, options: [], format: nil ) as? [String:String] else {
            throw MIOCoreDataToolError.couldNotParseVersionPlist
        }
        guard let path = plist[ "_XCCurrentVersionName" ] else {
            throw MIOCoreDataToolError.versionPlistHasNoCurrentVersionKey
        }
                
        let input_path = modeFilePath + "/" + path + "/contents"
        
        let parser = DataModelParser( modelFilePath: input_path )
        parser.outputDelegate = SwiftModelOutput( outputPath: outputFolderPath, objcSupport: objcSupport )
        
        try parser.execute()
    }
}
