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

    private var grid: [Address: Element] = [:]

    init() { }

    public subscript(row: Key, column: Key) -> Element? {
        get {
            let address = gridAddressFor(row: row, column: column)
            return grid[address]
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

        let address = gridAddressFor(row: row, column: column)
        let oldValue = grid[address]
        grid[address] = value
        return oldValue
    }

    @discardableResult
    public func removeValueFor(row: Key, column: Key) -> Element? {
        let address = gridAddressFor(row: row, column: column)
        let oldValue = grid[address]
        grid[address] = nil
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
        for key in gridAddressesWith(row: row) {
            grid.removeValue(forKey: key)
        }
    }

    public func remove(column: Key) {
        columns.remove(column)
        for key in gridAddressesWith(column: column) {
            grid.removeValue(forKey: key)
        }
    }

    public func valuesOf(column: Key) -> [Key: Element]? {
        guard columns.contains(column) else { return nil }
        var output: [Key: Element] = [:]
        for address in gridAddressesWith(column: column) {
            if let value = grid[address] {
                output.updateValue(value, forKey: address.row)
            }
        }
        return output
    }

    public func valuesOf(row: Key) -> [Key: Element]? {
        guard rows.contains(row) else { return nil }
        var output: [Key: Element] = [:]
        for address in gridAddressesWith(row: row) {
            if let value = grid[address] {
                output.updateValue(value, forKey: address.column)
            }
        }
        return output
    }

    private func gridAddressesWith(row: Key) -> [Address] {
        return grid.keys.filter { $0.row == row }
    }

    private func gridAddressesWith(column: Key) -> [Address] {
        return grid.keys.filter { $0.column == column }
    }

    private func gridAddressFor(row: Key, column: Key) -> Address {
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
