//
//  ConsoleLogger.swift
//  App
//
//  Created by Stefano Mondino on 17/07/18.
//  Copyright © 2018 Deltatre. All rights reserved.
//

import Foundation
import os

public actor ConsoleLogger: LoggerType {
    let logFileLines: Bool
    public init(logLevel: Logger.Level, logFileLines: Bool = true) {
        self.logLevel = logLevel
        self.logFileLines = logFileLines
    }

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY HH:mm:ss.sss"
        return formatter
    }()

    public let logLevel: Logger.Level
    public var isEnabled: Bool = true

    public func log(_ logLine: LogLine) async {
        let level = logLine.level
        guard
            isEnabled,
            logLevel != .none,
            level != .none,
            level.rawValue >= logLevel.rawValue else { return }

//            let logLevel: OSLogType
        let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: logLine.tag.description)
        let message = "\([logLine.fileString(), logLine.message.description].compactMap { $0 }.joined(separator: "\n"))"
        switch level {
        case .debug: logger.debug("\(message)")
        case .error: logger.error("\(message)")
        case .warning:
            logger.warning("\(message)")
        default: logger.log(level: .default, "\(message)")
        }
    }

    func log(_ message: Any,
             level: Logger.Level = .error,
             tag: String? = nil,
             file: String = #file,
             line: UInt = #line,
             function: String = #function) {
        guard
            isEnabled,
            logLevel != .none,
            level != .none,
            level.rawValue >= logLevel.rawValue else { return }

        let description = String(describing: message)
        let trimmedFile: String = if let lastIndex = file.lastIndex(of: "/") {
            String(file[file.index(after: lastIndex) ..< file.endIndex])
        } else {
            file
        }
        let fileString: String? = logFileLines ? "\(trimmedFile):\(line) (\(function))" : nil

        if #available(iOS 14.0, *) {
            let logLevel: OSLogType = switch level {
            case .debug: .debug
            case .error: .error
            default: .info
            }
            let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: tag ?? "")
            logger.log(level: logLevel, "\([fileString, description, "--------------"].compactMap { $0 }.joined(separator: "\n"))")
        } else {
            let date = dateFormatter.string(from: Date())
            let tagString: String? = if let tag { "[\(tag)]" } else { nil }
            let string =
                """
                \([[[tagString, date].compactMap { $0 }.joined(separator: " "),
                    [fileString].compactMap { $0 }.joined()].joined(separator: " - "),
                   description].compactMap { $0 }.joined(separator: " -> ")
                )
                """
            print(string)
        }
    }
}
