//
//  Symbol.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/24/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import SpriteKit

enum SymbolType: Int, Printable {
	case Unknown = 0, MyloXyloto, HurtsLikeHeaven, Paradise, CharlieBrown, UsAgainstTheWorld, MMIX, EveryTeardropIsAWaterfall, MajorMinus, UFO, PrincessOfChina, UpInFlames, AHopefulTransmission, DontLetItBreakYourHeart, UpWithTheBirds
	
	var spriteName: String
	{
		let spriteNames = [
			"MyloXyloto",
			"HurtsLikeHeaven",
			"Paradise",
			"CharlieBrown",
			"UsAgainstTheWorld",
			"MMIX",
			"EveryTeardropIsAWaterfall",
			"MajorMinus",
			"UFO",
			"PrincessOfChina",
			"UpInFlames",
			"AHopefullTransmission",
			"DontLetItBreakYourHeart",
			"UpWithTheBirds"]
			
		return spriteNames[rawValue - 1]
	}
 
	var highlightedSpriteName: String {
		return spriteName + "-Highlighted"
	}
	
	var description: String {
		return spriteName
	}
	
	//let numSymbols = 14
	static func random() -> SymbolType {
		return SymbolType(rawValue: Int(arc4random_uniform(6)) + 1)!
	}
}

class Symbol: Printable, Hashable {
	var column: Int
	var row: Int
	let symbolType: SymbolType
	var sprite: SKSpriteNode?
	
	var description: String {
		return "type:\(symbolType) square:(\(column),\(row))"
	}
	
	var hashValue: Int {
		return row*10 + column
	}
 
	init(column: Int, row: Int, symbolType: SymbolType) {
		self.column = column
		self.row = row
		self.symbolType = symbolType
	}
}

func ==(lhs: Symbol, rhs: Symbol) -> Bool {
	return lhs.column == rhs.column && lhs.row == rhs.row
}