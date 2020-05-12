//
//  Table.swift
//  MapirServices
//
//  Created by Alireza Asadi on 26/6/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

/// Table is a 2-Dimensional dictionary. It consist of rows and columns. In a table,
/// every value is stored using two keys, its row and column.
///
///
public class Table<Key: Hashable, Element> {

    /// Contains the rows of the table.
    public private(set) var rows: Set<Key> = []

    /// Contains the columns of the table.
    public private(set) var columns: Set<Key> = []

    /// Stores content of the table.
    private var table: [Address: Element] = [:]

    /// Creates an empty table.
    public init() { }

    /// Accesses the value at the specified row and column of the table.
    ///
    /// - parameters:
    ///   - row: The row in the table.
    ///   - column: The column in the table.
    ///
    /// - returns: The value associated with the row and column.
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

    /// Updates the value at a certain row and column. Returns the old value at the
    /// address.
    ///
    /// If the row and/or the column are not available in the table, they will be added.
    ///
    /// - Parameters:
    ///   - value: The value which is wanted to be added to the table.
    ///   - row: The row of the cell.
    ///   - column: The column of the cell.
    ///
    /// - returns: the old value at the address.
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

    /// Removes the value at the certain address. Returns the removed value.
    ///
    /// - Parameters:
    ///   - row: The row of the cell.
    ///   - column: The column of the cell.
    ///
    /// - returns: The removed value.
    @discardableResult
    public func removeValueFor(row: Key, column: Key) -> Element? {
        let address = tableAddressFor(row: row, column: column)
        let oldValue = table[address]
        table[address] = nil
        return oldValue
    }

    /// Inserts a new row to the table.
    ///
    /// If a row with the same `hashValue` exists, nothing happens.
    ///
    /// - Parameter row: The key for the new row.
    ///
    /// - returns: The added row. If row exists, returns nil.
    @discardableResult
    public func insert(row: Key) -> Key? {
        guard !rows.contains(row) else {
            return nil
        }
        rows.insert(row)
        return row
    }

    /// Inserts a new column to the table.
    ///
    /// If a column with the same `hashValue` exists, nothing happens.
    ///
    /// - Parameter column: The key for the new row.
    ///
    /// - returns: The added column. If column exists, returns nil.
    @discardableResult
    public func insert(column: Key) -> Key? {
        guard !columns.contains(column) else {
            return nil
        }
        columns.insert(column)
        return column
    }

    /// Removes a row and removes every cell associated with it.
    ///
    /// - Parameter row: The row to remove.
    ///
    /// - returns: A dictionary of removed values associated with their columns. Returns
    ///   nil if the rows does not exist.
    @discardableResult
    public func remove(row: Key) -> [Key: Element]? {
        if rows.contains(row) {
            rows.remove(row)
            var cells: [Key: Element] = [:]
            for key in tableAddressesWith(row: row) {
                if let value = table.removeValue(forKey: key) {
                    cells[key.column] = value
                }
            }
            return cells
        } else {
            return nil
        }
    }

    /// Removes a column and removes every cell associated with it.
    ///
    /// - Parameter column: The column to remove.
    ///
    /// - returns: A dictionary of removed values associated with their rows. Returns
    ///   nil if the column does not exist.
    public func remove(column: Key) -> [Key: Element]? {
        if columns.contains(column) {
            columns.remove(column)
            var cells: [Key: Element] = [:]
            for key in tableAddressesWith(column: column) {
                if let value = table.removeValue(forKey: key) {
                    cells[key.row] = value
                }
            }
            return cells
        } else {
            return nil
        }

    }

    /// Returns all values in a certain column. Returns nil if column does not exist.
    ///
    /// - Parameter column: The target column.
    ///
    /// - returns: Values in a certain column or nil if column does not exist.
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

    /// Returns all values in a certain row. Returns nil if row does not exist.
    ///
    /// - Parameter row: The target row.
    ///
    /// - returns: Values in a certain row or nil if row does not exist.
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
}

// MARK: Working with addresses

extension Table {

    /// Combines the row and column in an address.
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

// MARK: Protocol conformance.

extension Table: Equatable, Hashable where Element: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rows)
        hasher.combine(columns)
        hasher.combine(table)
    }

    static public func == (_ lhs: Table, _ rhs: Table) -> Bool {
        lhs.rows == rhs.rows &&
            lhs.columns == rhs.columns &&
            lhs.table == rhs.table
    }

}

extension Table: CustomStringConvertible, CustomDebugStringConvertible
where Key: CustomStringConvertible, Element: CustomStringConvertible {

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

    public var debugDescription: String { return description }
}
