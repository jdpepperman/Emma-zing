//
//  Chain.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/26/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

class Chain: Hashable, Printable {
	var symbols = [Symbol]()
	
	var score = 0
 
	enum ChainType: Printable {
		case Horizontal
		case Vertical
		
		var description: String {
			switch self {
			case .Horizontal: return "Horizontal"
			case .Vertical: return "Vertical"
			}
		}
	}
 
	var chainType: ChainType
 
	init(chainType: ChainType) {
		self.chainType = chainType
	}
 
	func addSymbol(symbol: Symbol) {
		symbols.append(symbol)
	}
 
	func firstSymbol() -> Symbol {
		return symbols[0]
	}
 
	func lastSymbol() -> Symbol {
		return symbols[symbols.count - 1]
	}
 
	var length: Int {
		return symbols.count
	}
 
	var description: String {
		return "type:\(chainType) symbols:\(symbols)"
	}
 
	var hashValue: Int {
		return reduce(symbols, 0) { $0.hashValue ^ $1.hashValue }
	}
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
	return lhs.symbols == rhs.symbols
}