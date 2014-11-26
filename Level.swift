//
//  Level.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/25/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level
{
	private var symbols = Array2D<Symbol>(columns: NumColumns, rows: NumRows)
	private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
	
	private var possibleSwaps = Set<Swap>()
 
	init(filename: String)
	{
		if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename)
		{
			if let tilesArray: AnyObject = dictionary["tiles"]
			{
				for (row, rowArray) in enumerate(tilesArray as [[Int]])
				{
					let tileRow = NumRows - row - 1
			
					for (column, value) in enumerate(rowArray)
					{
						if value == 1
						{
							tiles[column, tileRow] = Tile()
						}
					}
				}
			}
		}
	}
	
	func performSwap(swap: Swap) {
		let columnA = swap.symbolA.column
		let rowA = swap.symbolA.row
		let columnB = swap.symbolB.column
		let rowB = swap.symbolB.row
			
		symbols[columnA, rowA] = swap.symbolB
		swap.symbolB.column = columnA
		swap.symbolB.row = rowA
			
		symbols[columnB, rowB] = swap.symbolA
		swap.symbolA.column = columnB
		swap.symbolA.row = rowB
	}
	
	func tileAtColumn(column: Int, row: Int) -> Tile? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return tiles[column, row]
	}
	
	func symbolAtColumn(column: Int, row: Int) -> Symbol? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return symbols[column, row]
	}
	
	func shuffle() -> Set<Cookie> {
		var set: Set<Cookie>
		do {
			set = createInitialCookies()
			detectPossibleSwaps()
			println("possible swaps: \(possibleSwaps)")
		}
		while possibleSwaps.count == 0
			
		return set
	}
	
	private func hasChainAtColumn(column: Int, row: Int) -> Bool {
		let cookieType = cookies[column, row]!.cookieType
			
		var horzLength = 1
		for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType; --i, ++horzLength { }
		for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType; ++i, ++horzLength { }
		if horzLength >= 3 { return true }
			
		var vertLength = 1
		for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType; --i, ++vertLength { }
		for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType; ++i, ++vertLength { }
		return vertLength >= 3
	}
	
	func detectPossibleSwaps() {
		var set = Set<Swap>()
			
		for row in 0..<NumRows {
		for column in 0..<NumColumns {
			if let cookie = cookies[column, row] {
				
				// TODO: detection logic goes here
			}
		}
	}
		
  possibleSwaps = set
	}
 
	private func createInitialsymbols() -> Set<Symbol> {
		var set = Set<Symbol>()
		
		for row in 0..<NumRows
		{
			for column in 0..<NumColumns
			{
				if tiles[column, row] != nil
				{
					//choose 6 of 14 original symbols?
					var symbolType: SymbolType
					do {
						symbolType = SymbolType.random()
					}
						while (column >= 2 &&
							symbols[column - 1, row]?.symbolType == symbolType &&
							symbols[column - 2, row]?.symbolType == symbolType)
							|| (row >= 2 &&
								symbols[column, row - 1]?.symbolType == symbolType &&
								symbols[column, row - 2]?.symbolType == symbolType)
			
					let symbol = Symbol(column: column, row: row, symbolType: symbolType)
					symbols[column, row] = symbol
			
					set.addElement(symbol)
				}
			}
		}
		
		return set
	}
}