//
//  Table.swift
//  MapirServices
//
//  Created by Alireza Asadi on 26/6/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

public class Table<Header: Hashable, Element> {

    public private(set) var rows: Set<Header> = []
    public private(set) var columns: Set<Header> = []

    private struct Address: Hashable {
        let row: Header
        let column: Header

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

    public subscript(row: Header, column: Header) -> Element? {
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
    public func updateValue(_ value: Element, row: Header, column: Header) -> Element? {
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
    public func removeValueFor(row: Header, column: Header) -> Element? {
        let address = gridAddressFor(row: row, column: column)
        let oldValue = grid[address]
        grid[address] = nil
        return oldValue
    }

    public func insert(row: Header) {
        guard !rows.contains(row) else {
            return
        }
        rows.insert(row)
    }

    public func insert(column: Header) {
        guard !columns.contains(column) else {
            return
        }
        columns.insert(column)
    }

    public func remove(row: Header) {
        rows.remove(row)
        for key in gridKeysWith(row: row) {
            grid.removeValue(forKey: key)
        }
    }

    public func remove(column: Header) {
        columns.remove(column)
        for key in gridKeysWith(column: column) {
            grid.removeValue(forKey: key)
        }
    }

    private func gridKeysWith(row: Header) -> [Address] {
        return grid.keys.filter { $0.row == row }
    }

    private func gridKeysWith(column: Header) -> [Address] {
        return grid.keys.filter { $0.column == column }
    }

    private func gridAddressFor(row: Header, column: Header) -> Address {
        Address(row: row, column: column)
    }

    private func isRowValid(row: Header) -> Bool {
        return rows.contains(row)
    }

    private func isColumnValid(column: Header) -> Bool {
        return columns.contains(column)
    }

    private func isAddressValid(row: Header, column: Header) -> Bool {
        return isRowValid(row: row) && isColumnValid(column: column)
    }
}
