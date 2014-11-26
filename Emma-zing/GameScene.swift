//
//  GameScene.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/24/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	var swipeHandler: ((Swap) -> ())?
	
	var level: Level!
	
	let TileWidth: CGFloat = 32.0
	let TileHeight: CGFloat = 36.0
	
	let gameLayer = SKNode()
	let symbolsLayer = SKNode()
	let tilesLayer = SKNode()
	
	var swipeFromColumn: Int?
	var swipeFromRow: Int?
	
	var selectionSprite = SKSpriteNode()
	
	let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
	let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
	let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
	let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
	let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) is not used in this app")
	}
 
	override init(size: CGSize) {
		super.init(size: size)
		
		anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		let background = SKSpriteNode(imageNamed: "Background")
		addChild(background)
		
		addChild(gameLayer)
		
		let layerPosition = CGPoint(
			x: -TileWidth * CGFloat(NumColumns) / 2,
			y: -TileHeight * CGFloat(NumRows) / 2)
		
		tilesLayer.position = layerPosition
		gameLayer.addChild(tilesLayer)
		
		symbolsLayer.position = layerPosition
		gameLayer.addChild(symbolsLayer)
		
		swipeFromColumn = nil
		swipeFromRow = nil
	}
	
	func addSpritesForSymbols(symbols: Set<Symbol>) {
		for symbol in symbols {
			let sprite = SKSpriteNode(imageNamed: symbol.symbolType.spriteName)
			sprite.position = pointForColumn(symbol.column, row:symbol.row)
			symbolsLayer.addChild(sprite)
			symbol.sprite = sprite
		}
	}
	
	func addTiles() {
		for row in 0..<NumRows {
			for column in 0..<NumColumns {
				if let tile = level.tileAtColumn(column, row: row) {
					let tileNode = SKSpriteNode(imageNamed: "Tile")
					tileNode.position = pointForColumn(column, row: row)
					tilesLayer.addChild(tileNode)
				}
			}
		}
	}
 
	func pointForColumn(column: Int, row: Int) -> CGPoint {
		return CGPoint(
			x: CGFloat(column)*TileWidth + TileWidth/2,
			y: CGFloat(row)*TileHeight + TileHeight/2
		)
	}
	
	func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int)
	{
		if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth && point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight
		{
				return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
		}
		else
		{
			return (false, 0, 0)  // invalid location
		}
	}
	
	func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
		let toColumn = swipeFromColumn! + horzDelta
		let toRow = swipeFromRow! + vertDelta
		
		if toColumn < 0 || toColumn >= NumColumns { return }
		
		if toRow < 0 || toRow >= NumRows { return }
		
		if let toSymbol = level.symbolAtColumn(toColumn, row: toRow)
		{
			if let fromSymbol = level.symbolAtColumn(swipeFromColumn!, row: swipeFromRow!)
			{
				if let handler = swipeHandler {
					let swap = Swap(symbolA: fromSymbol, symbolB: toSymbol)
					handler(swap)
				}
			}
		}
	}
	
	func animateSwap(swap: Swap, completion: () -> ()) {
		let spriteA = swap.symbolA.sprite!
		let spriteB = swap.symbolB.sprite!
			
		spriteA.zPosition = 100
		spriteB.zPosition = 90
			
		let Duration: NSTimeInterval = 0.3
			
		let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
		moveA.timingMode = .EaseOut
		spriteA.runAction(moveA, completion: completion)
			
		let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
		moveB.timingMode = .EaseOut
		spriteB.runAction(moveB)
		
		//runAction(swapSound)
	}
	
	func animateInvalidSwap(swap: Swap, completion: () -> ()) {
		let spriteA = swap.symbolA.sprite!
		let spriteB = swap.symbolB.sprite!
			
		spriteA.zPosition = 100
		spriteB.zPosition = 90
			
		let Duration: NSTimeInterval = 0.2
			
		let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
		moveA.timingMode = .EaseOut
			
		let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
		moveB.timingMode = .EaseOut
			
		spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
		spriteB.runAction(SKAction.sequence([moveB, moveA]))
		
		//runAction(invalidSwapSound)
	}
	
	func showSelectionIndicatorForSymbol(symbol: Symbol) {
		if selectionSprite.parent != nil
		{
			selectionSprite.removeFromParent()
		}
			
		if let sprite = symbol.sprite
		{
			let texture = SKTexture(imageNamed: symbol.symbolType.highlightedSpriteName)
			selectionSprite.size = texture.size()
			selectionSprite.runAction(SKAction.setTexture(texture))

			sprite.addChild(selectionSprite)
			selectionSprite.alpha = 1.0
		}
	}
	
	func hideSelectionIndicator() {
		selectionSprite.runAction(SKAction.sequence([
			SKAction.fadeOutWithDuration(0.3),
			SKAction.removeFromParent()]))
	}
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let touch = touches.anyObject() as UITouch
		let location = touch.locationInNode(symbolsLayer)
		
		let (success, column, row) = convertPoint(location)
		if success
		{
			if let symbol = level.symbolAtColumn(column, row: row)
			{
				showSelectionIndicatorForSymbol(symbol)
				swipeFromColumn = column
				swipeFromRow = row
			}
		}
	}
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		if swipeFromColumn == nil { return }

		let touch = touches.anyObject() as UITouch
		let location = touch.locationInNode(symbolsLayer)
				
		let (success, column, row) = convertPoint(location)
		if success {
			var horzDelta = 0, vertDelta = 0
			
			if column < swipeFromColumn! {          // swipe left
				horzDelta = -1
			}
			else if column > swipeFromColumn! {   // swipe right
				horzDelta = 1
			}
			else if row < swipeFromRow! {         // swipe down
				vertDelta = -1
			}
			else if row > swipeFromRow! {         // swipe up
				vertDelta = 1
			}

			if horzDelta != 0 || vertDelta != 0 {
				trySwapHorizontal(horzDelta, vertical: vertDelta)
				hideSelectionIndicator()

				swipeFromColumn = nil
			}
		}
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		if selectionSprite.parent != nil && swipeFromColumn != nil {
			hideSelectionIndicator()
		}
		
		swipeFromColumn = nil
		swipeFromRow = nil
	}
 
	override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
		touchesEnded(touches, withEvent: event)
	}
}