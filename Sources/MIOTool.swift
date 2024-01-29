// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct MIOTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A swift command-line tool to manage all swift related mio libraries",
        subcommands: [ModelCommand.self]
    )
    
//    mutating func run() throws {
//        print("Hello, world!")
//    }
}
