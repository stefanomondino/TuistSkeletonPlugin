// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(accessor)
public macro Case(_ name: String = "") = #externalMacro(module: "DataStructuresMacros", type: "CaseMacro")
