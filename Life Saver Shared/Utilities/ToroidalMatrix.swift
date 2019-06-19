//
//  ToroidalMatrix.swift
//  Derived from dimo hamdy https://stackoverflow.com/a/53421491/2117288
//  https://gist.github.com/amiantos/bb0f313da1ee686f4f69b8b44f3cd184
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

struct ToroidalMatrix<T> {
    let rows: Int, columns: Int
    var grid: [T]

    init(rows: Int, columns: Int, defaultValue: T) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultValue, count: rows * columns)
    }

    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    subscript(row: Int, column: Int) -> T {
        get {
            let safeRow = 0 ... rows - 1 ~= row ? row : row > rows - 1 ? 0 : row < 0 ? rows - 1 : -1
            let safeColumn = 0 ... columns - 1 ~= column ? column : column > columns - 1 ? 0 : column < 0 ? columns - 1 : -1
            assert(indexIsValid(row: safeRow, column: safeColumn), "Index out of range")
            return grid[(safeRow * columns) + safeColumn]
        }

        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
