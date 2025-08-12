//
//  DataResponseTests.swift
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

import Testing
import Foundation
@testable import Resplash

struct DataResponseTests {
  struct Model: Decodable {
    let id: Int
    let name: String
  }

  @Test func decode() throws {
    let json = Data(
      """
      {
        "id": 10,
        "name": "Jaesung Jung"
      }
      """.utf8
    )
    let response = try JSONDecoder().decode(Unsplash.DataResponse.self, from: json)
    let model = try response.decode(Model.self)
    #expect(model.id == 10)
    #expect(model.name == "Jaesung Jung")
  }

  @Test func decodeNestedObject() throws {
    let json = Data(
      """
      {
        "user": {
          "id": 10,
          "name": "Jaesung Jung"
        }
      }
      """.utf8
    )
    let response = try JSONDecoder().decode(Unsplash.DataResponse.self, from: json)
    let model = try response.decode(Model.self, forKey: "user")
    #expect(model.id == 10)
    #expect(model.name == "Jaesung Jung")
  }

  @Test func decodeNestedObject2() throws {
    let json = Data(
      """
      {
        "user": {
          "data": {
            "id": 10,
            "name": "Jaesung Jung"
          }
        }
      }
      """.utf8
    )
    let response = try JSONDecoder().decode(Unsplash.DataResponse.self, from: json)
    let model = try response.decode(Model.self, forKey: "user.data")
    #expect(model.id == 10)
    #expect(model.name == "Jaesung Jung")
  }
}
