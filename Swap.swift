//
//  Swap.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/26/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

struct Swap: Printable, Hashable
{
	let symbolA: Symbol
	let symbolB: Symbol
 
	init(symbolA: Symbol, symbolB: Symbol)
	{
		self.symbolA = symbolA
		self.symbolB = symbolB
	}
 
	var description: String
		{
		return "swap \(symbolA) with \(symbolB)"
	}
	
	var hashValue: Int {
		return symbolA.hashValue ^ symbolB.hashValue
	}
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
	return (lhs.symbolA == rhs.symbolA && lhs.symbolB == rhs.symbolB) ||
		(lhs.symbolB == rhs.symbolA && lhs.symbolA == rhs.symbolB)
}