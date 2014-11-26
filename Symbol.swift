//
//  Symbol.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/24/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import SpriteKit

enum SymbolType: Int {
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
			"AHopefulTransmission",
			"DontLetItBreakYourHeart",
			"UpWithTheBirds"]
			
		return spriteNames[rawValue - 1]
	}
 
	var highlightedSpriteName: String {
		return spriteName + "-Highlighted"
	}
}

class Symbol {
	var column: Int
	var row: Int
	let symbolType: SymbolType
	var sprite: SKSpriteNode?
 
	init(column: Int, row: Int, symbolType: SymbolType) {
		self.column = column
		self.row = row
		self.symbolType = symbolType
	}
}