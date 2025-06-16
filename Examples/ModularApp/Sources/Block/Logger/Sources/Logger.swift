//
//  Logger.swift
//  Core
//
//  Created by Stefano Mondino on 13/07/2020.
//

import Foundation

public protocol LoggerType: Sendable {
    func log(_ logLine: LogLine) async
}

public actor Logger {
    private var loggers: [LoggerType] = []

    public static let shared = Logger()

    public init() {}

    public func add(logger: LoggerType) {
        loggers.append(logger)
    }

    public static func log(_ message: Any,
                           level: Level = .verbose,
                           tag: Tag = .none,
                           file: String = #file,
                           line: UInt = #line,
                           function: String = #function) {
        log(.init(message: String(describing: message),
                  level: level,
                  tag: tag,
                  file: file,
                  line: line,
                  function: function))
    }

    public static func log(_ logLine: LogLine) {
        Task { await shared.log(logLine) }
    }

    public func log(_ logLine: LogLine) async {
        for logger in loggers {
            await logger.log(logLine)
        }
    }
}
