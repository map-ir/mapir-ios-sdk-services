//
//  Table.swift
//  MapirServices
//
//  Created by Alireza Asadi on 26/6/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

public class Table<Key: Hashable, Element> {

    public private(set) var rows: Set<Key> = []
    public private(set) var columns: Set<Key> = []

    private struct Address: Hashable {
        let row: Key
        let column: Key

        func hash(into hasher: inout Hasher) {
            hasher.combine(row)
            hasher.combine(column)
        }

        static func == (_ lhs: Address, _ rhs: Address) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }

    private var table: [Address: Element] = [:]

    init() { }

    public subscript(row: Key, column: Key) -> Element? {
        get {
            let address = tableAddressFor(row: row, column: column)
            return table[address]
        }
        set {
            if let newValue = newValue {
                self.updateValue(newValue, row: row, column: column)
            } else {
                self.removeValueFor(row: row, column: column)
            }
        }
    }

    @discardableResult
    public func updateValue(_ value: Element, row: Key, column: Key) -> Element? {
        if !isRowValid(row: row) {
            rows.insert(row)
        }
        if !isColumnValid(column: column) {
            columns.insert(column)
        }

        let address = tableAddressFor(row: row, column: column)
        let oldValue = table[address]
        table[address] = value
        return oldValue
    }

    @discardableResult
    public func removeValueFor(row: Key, column: Key) -> Element? {
        let address = tableAddressFor(row: row, column: column)
        let oldValue = table[address]
        table[address] = nil
        return oldValue
    }

    public func insert(row: Key) {
        guard !rows.contains(row) else {
            return
        }
        rows.insert(row)
    }

    public func insert(column: Key) {
        guard !columns.contains(column) else {
            return
        }
        columns.insert(column)
    }

    public func remove(row: Key) {
        rows.remove(row)
        for key in tableAddressesWith(row: row) {
            table.removeValue(forKey: key)
        }
    }

    public func remove(column: Key) {
        columns.remove(column)
        for key in tableAddressesWith(column: column) {
            table.removeValue(forKey: key)
        }
    }

    public func valuesOf(column: Key) -> [Key: Element]? {
        guard columns.contains(column) else { return nil }
        var output: [Key: Element] = [:]
        for address in tableAddressesWith(column: column) {
            if let value = table[address] {
                output.updateValue(value, forKey: address.row)
            }
        }
        return output
    }

    public func valuesOf(row: Key) -> [Key: Element]? {
        guard rows.contains(row) else { return nil }
        var output: [Key: Element] = [:]
        for address in tableAddressesWith(row: row) {
            if let value = table[address] {
                output.updateValue(value, forKey: address.column)
            }
        }
        return output
    }

    private func tableAddressesWith(row: Key) -> [Address] {
        return table.keys.filter { $0.row == row }
    }

    private func tableAddressesWith(column: Key) -> [Address] {
        return table.keys.filter { $0.column == column }
    }

    private func tableAddressFor(row: Key, column: Key) -> Address {
        return Address(row: row, column: column)
    }

    private func isRowValid(row: Key) -> Bool {
        return rows.contains(row)
    }

    private func isColumnValid(column: Key) -> Bool {
        return columns.contains(column)
    }

    private func isAddressValid(row: Key, column: Key) -> Bool {
        return isRowValid(row: row) && isColumnValid(column: column)
    }
}

extension Table: CustomStringConvertible where Key: CustomStringConvertible, Element: CustomStringConvertible {
    public var description: String {

        guard !rows.isEmpty || !columns.isEmpty else { return "Table is empty." }

        let columns = self.columns
        let rows = self.rows

        var columnWidths = [rows.map { $0.description.count }.max() ?? 2]
        for col in columns {
            var maximum: Int = col.description.count
            if let values = valuesOf(column: col) {
                maximum = max(values.map { $1.description.count }.max() ?? 5, maximum)
            } else {
                maximum = max(5, maximum)
            }
            columnWidths.append(maximum)
        }
        columnWidths = columnWidths.map { $0 + 2 }

        var desc = ("|" + String(repeating: "X", count: columnWidths[0] - 2))
            .padding(toLength: columnWidths[0] - 1, withPad: " ", startingAt: 0)

        for col in Array(columns).enumerated() {
            let word = "|\(col.element.description)"
                .padding(toLength: columnWidths[col.offset + 1], withPad: " ", startingAt: 0)

            desc.append(word)
        }
        desc.append("|")

        for row in rows.enumerated() {
            let word = "\n|\(row.element)"
                .padding(toLength: columnWidths[0], withPad: " ", startingAt: 0)

            desc.append(word)

            for col in columns.enumerated() {
                let word = ("|" + (self[row.element, col.element]?.description ?? " "))
                    .padding(toLength: columnWidths[col.offset + 1], withPad: " ", startingAt: 0)

                desc.append(word)
            }
            desc.append("|")
        }
        return desc
    }
}
