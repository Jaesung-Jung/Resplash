//
//  OSLogBackend.swift
//
//  Copyright © 2025 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Logging
import os

public typealias Logger = Logging.Logger
public typealias OSLogger = os.Logger

public struct OSLogBackend: LogHandler {
  private let label: String

  public var logLevel: Logger.Level = .debug
  public var metadataProvider: Logger.MetadataProvider?

  private var prettyMetadata: String?
  public var metadata = Logger.Metadata() {
    didSet {
      self.prettyMetadata = self.prettify(self.metadata)
    }
  }

  public init(label: String) {
    self.label = label
    self.metadataProvider = LoggingSystem.metadataProvider
  }

  public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata.Value? {
    get { metadata[metadataKey] }
    set { metadata[metadataKey] = newValue }
  }

  public func log(
    level: Logger.Level,
    message: Logger.Message,
    metadata explicitMetadata: Logger.Metadata?,
    source: String,
    file: String,
    function: String,
    line: UInt
  ) {
    let effectiveMetadata = OSLogBackend.prepareMetadata(
      base: self.metadata,
      provider: self.metadataProvider,
      explicit: explicitMetadata
    )

    let prettyMetadata = if let effectiveMetadata {
      prettify(effectiveMetadata)
    } else {
      prettyMetadata
    }

    let logger = OSLogger(subsystem: label, category: source)
    if let prettyMetadata {
      logger.log(level: OSLogBackend.osLogType(level), "\(message)\n[\(prettyMetadata)]")
    } else {
      logger.log(level: OSLogBackend.osLogType(level), "\(message)")
    }
  }
}

extension OSLogBackend {
  private func prettify(_ metadata: Logger.Metadata) -> String? {
    if metadata.isEmpty {
      return nil
    }
    return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: ", ")
  }
}

extension OSLogBackend {
  static func prepareMetadata(base: Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata? {
    var metadata = base
    let provided = provider?.get() ?? [:]

    guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
      return nil
    }

    if !provided.isEmpty {
      metadata.merge(provided) { $1 }
    }
    if let explicit, !explicit.isEmpty {
      metadata.merge(explicit) { $1 }
    }
    return metadata
  }

  static func osLogType(_ level: Logger.Level) -> OSLogType {
    switch level {
    case .trace:
      return .debug
    case .debug:
      return .debug
    case .info:
      return .info
    case .notice:
      return .default
    case .warning:
      return .info
    case .error:
      return .error
    case .critical:
      return .fault
    }
  }
}
