//
//  ArrayBuilder.swift
//  Resplash
//
//  Created by 정재성 on 7/22/25.
//

@resultBuilder struct ArrayBuilder<Item> {
  static func buildBlock(_ items: Item...) -> [Item] {
    items
  }

  static func buildBlock(_ items: [Item]...) -> [Item] {
    items.flatMap { $0 }
  }

  static func buildOptional(_ items: [Item]?) -> [Item] {
    items ?? []
  }

  static func buildEither(first items: [Item]) -> [Item] {
    items
  }

  static func buildEither(second items: [Item]) -> [Item] {
    items
  }

  static func buildExpression(_ expression: Item) -> [Item] {
    [expression]
  }

  static func buildExpression<C: Collection>(_ expression: C) -> [Item] where C.Element == Item {
    Array(expression)
  }

  static func buildArray(_ components: [[Item]]) -> [Item] {
    components.flatMap { $0 }
  }

  static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
    component
  }
}
