//
//  ModelCommand.swift
//
//
//  Created by Javier Segura Perez on 29/1/24.
//

import Foundation
import ArgumentParser

struct ModelCommand: ParsableCommand
{
    static var configuration = CommandConfiguration(
        commandName: "model",
        abstract: "model command tools",
        subcommands: [GenerateModelCommand.self]
    )
}
