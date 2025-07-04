//
//  StringCodingKey.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

struct StringCodingKey: CodingKey {
  let stringValue: String
  let intValue: Int?

  init?(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = Int(stringValue)
  }

  init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = "\(intValue)"
  }

  init?<S: StringProtocol>(_ string: S) {
    self.init(stringValue: String(string))
  }
}

// MARK: - StringCodingKey (ExpressibleByStringLiteral)

extension StringCodingKey: ExpressibleByStringLiteral {
  init(stringLiteral: StringLiteralType) {
    self.stringValue = stringLiteral
    self.intValue = Int(stringLiteral)
  }
}
