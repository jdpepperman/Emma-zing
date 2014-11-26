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
	let targetScore: Int!
	let maximumMoves: Int!
	
	private var symbols = Array2D<Symbol>(columns: NumColumns, rows: NumRows)
	private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
	
	private var possibleSwaps = Set<Swap>()
	
	var symbolsForThisLevel: [Int] = []
	
	private var comboMultiplier = 0

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
				targetScore = (dictionary["targetScore"] as NSNumber).integerValue
				maximumMoves = (dictionary["moves"] as NSNumber).integerValue
			}
		}
		
		//initialize symbols for this level. count should be between 3 and 14.
		while symbolsForThisLevel.count < 6
		{
			var symbolNum = Int(arc4random_uniform(14)) + 1
			if !(contains(symbolsForThisLevel, symbolNum))
			{
				symbolsForThisLevel.append(symbolNum)
			}
			
		}
	}
	
	func isPossibleSwap(swap: Swap) -> Bool {
		return possibleSwaps.containsElement(swap)
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
	
	func shuffle() -> Set<Symbol> {
		var set: Set<Symbol>
		do {
			set = createInitialSymbols()
			detectPossibleSwaps()
			println("possible swaps: \(possibleSwaps)")
		}
		while possibleSwaps.count == 0
			
		return set
	}
	
	private func hasChainAtColumn(column: Int, row: Int) -> Bool {
		let symbolType = symbols[column, row]!.symbolType
			
		var horzLength = 1
		for var i = column - 1; i >= 0 && symbols[i, row]?.symbolType == symbolType; --i, ++horzLength { }
		for var i = column + 1; i < NumColumns && symbols[i, row]?.symbolType == symbolType; ++i, ++horzLength { }
		if horzLength >= 3 { return true }
			
		var vertLength = 1
		for var i = row - 1; i >= 0 && symbols[column, i]?.symbolType == symbolType; --i, ++vertLength { }
		for var i = row + 1; i < NumRows && symbols[column, i]?.symbolType == symbolType; ++i, ++vertLength { }
		return vertLength >= 3
	}
	
	func detectPossibleSwaps() {
		var set = Set<Swap>()
			
		for row in 0..<NumRows {
			for column in 0..<NumColumns {
				if let symbol = symbols[column, row] {
					
					// Is it possible to swap this symbol with the one on the right?
					if column < NumColumns - 1 {
						// Have a symbol in this spot? If there is no tile, there is no symbol.
						if let other = symbols[column + 1, row] {
							// Swap them
							symbols[column, row] = other
							symbols[column + 1, row] = symbol
							
							// Is either symbol now part of a chain?
							if hasChainAtColumn(column + 1, row: row) || hasChainAtColumn(column, row: row) {
									set.addElement(Swap(symbolA: symbol, symbolB: other))
							}
							
							// Swap them back
							symbols[column, row] = symbol
							symbols[column + 1, row] = other
						}
					}
					if row < NumRows - 1 {
						if let other = symbols[column, row + 1] {
							symbols[column, row] = other
							symbols[column, row + 1] = symbol
							
							// Is either symbol now part of a chain?
							if hasChainAtColumn(column, row: row + 1) || hasChainAtColumn(column, row: row) {
									set.addElement(Swap(symbolA: symbol, symbolB: other))
							}
							
							// Swap them back
							symbols[column, row] = symbol
							symbols[column, row + 1] = other
						}
					}
				}
			}
		}
		
		possibleSwaps = set
	}
	
	private func detectHorizontalMatches() -> Set<Chain> {
		var set = Set<Chain>()
		
		for row in 0..<NumRows {
			for var column = 0; column < NumColumns - 2 ; {
				
				if let symbol = symbols[column, row] {
					let matchType = symbol.symbolType

					if symbols[column + 1, row]?.symbolType == matchType && symbols[column + 2, row]?.symbolType == matchType {
						let chain = Chain(chainType: .Horizontal)
						
						do {
							chain.addSymbol(symbols[column, row]!)
							++column
						}
						while column < NumColumns && symbols[column, row]?.symbolType == matchType
						
						set.addElement(chain)
						continue
					}
				}
			++column
			}
		}
		return set
	}
	
	private func detectVerticalMatches() -> Set<Chain> {
		var set = Set<Chain>()
			
		for column in 0..<NumColumns {
			for var row = 0; row < NumRows - 2; {
				if let symbol = symbols[column, row] {
					let matchType = symbol.symbolType
				
					if symbols[column, row + 1]?.symbolType == matchType && symbols[column, row + 2]?.symbolType == matchType {
						
						let chain = Chain(chainType: .Vertical)
						do {
							chain.addSymbol(symbols[column, row]!)
							++row
						}
						while row < NumRows && symbols[column, row]?.symbolType == matchType
						
						set.addElement(chain)
						continue
					}
				}
				++row
			}
		}
		return set
	}
	
	private func removeSymbols(chains: Set<Chain>) {
		for chain in chains {
			for symbol in chain.symbols {
				symbols[symbol.column, symbol.row] = nil
			}
		}
	}
	
	func removeMatches() -> Set<Chain> {
		let horizontalChains = detectHorizontalMatches()
		let verticalChains = detectVerticalMatches()
			
		removeSymbols(horizontalChains)
		removeSymbols(verticalChains)
		
		calculateScores(horizontalChains)
		calculateScores(verticalChains)
			
		return horizontalChains.unionSet(verticalChains)
	}
	
	func fillHoles() -> [[Symbol]] {
		var columns = [[Symbol]]()
		
		for column in 0..<NumColumns {
			var array = [Symbol]()
			
			for row in 0..<NumRows {
				if tiles[column, row] != nil && symbols[column, row] == nil {
					for lookup in (row + 1)..<NumRows {
						if let symbol = symbols[column, lookup] {
							
							symbols[column, lookup] = nil
							symbols[column, row] = symbol
							symbol.row = row
							
							array.append(symbol)
							
							break
						}
					}
				}
			}
			if !array.isEmpty {
				columns.append(array)
			}
		}
		return columns
	}
	
	func topUpSymbols() -> [[Symbol]] {
		var columns = [[Symbol]]()
		var symbolType: SymbolType = .Unknown
			
		for column in 0..<NumColumns {
			var array = [Symbol]()
			
			for var row = NumRows - 1; row >= 0 && symbols[column, row] == nil; --row {
				
				if tiles[column, row] != nil {
					
					var newSymbolType: SymbolType
					do {
						newSymbolType = SymbolType.random(symbolsForThisLevel)
					} while newSymbolType == symbolType
					symbolType = newSymbolType
					
					let symbol = Symbol(column: column, row: row, symbolType: symbolType)
					symbols[column, row] = symbol
					array.append(symbol)
				}
			}
			
			if !array.isEmpty {
				columns.append(array)
			}
		}
		return columns
	}
 
	private func createInitialSymbols() -> Set<Symbol> {
		var set = Set<Symbol>()
		
		println(symbolsForThisLevel)
		
		for row in 0..<NumRows
		{
			for column in 0..<NumColumns
			{
				if tiles[column, row] != nil
				{
					var symbolType: SymbolType
					do {
						symbolType = SymbolType.random(symbolsForThisLevel)
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
	
	private func calculateScores(chains: Set<Chain>) {
		// 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
		for chain in chains {
			chain.score = 60 * (chain.length - 2) * comboMultiplier
			++comboMultiplier
		}
	}
	
	func resetComboMultiplier() {
		comboMultiplier = 1
	}
}