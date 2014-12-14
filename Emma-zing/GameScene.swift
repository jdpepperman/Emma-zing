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
	
	var isMuted: Bool = false
	let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
	let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
	let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
	let fallingSymbolSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
	let addSymbolSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
	let warningSound = SKAction.playSoundFileNamed("warning.mp3", waitForCompletion: false)
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) is not used in this app")
	}
 
	override init(size: CGSize) {
		super.init(size: size)
		
		anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		let background = SKSpriteNode(imageNamed: "Background")
		addChild(background)
		
		addChild(gameLayer)
		gameLayer.hidden = true
		
		let layerPosition = CGPoint(
			x: -TileWidth * CGFloat(NumColumns) / 2,
			y: -TileHeight * CGFloat(NumRows) / 2)
		
		tilesLayer.position = layerPosition
		gameLayer.addChild(tilesLayer)
		
		symbolsLayer.position = layerPosition
		gameLayer.addChild(symbolsLayer)
		
		swipeFromColumn = nil
		swipeFromRow = nil
		
		SKLabelNode(fontNamed: "GillSans-BoldItalic")
	}
	
	func addSpritesForSymbols(symbols: Set<Symbol>) {
		for symbol in symbols {
			let sprite = SKSpriteNode(imageNamed: symbol.symbolType.spriteName)
			sprite.position = pointForColumn(symbol.column, row:symbol.row)
			symbolsLayer.addChild(sprite)
			symbol.sprite = sprite
		
		
			// Give each cookie sprite a small, random delay. Then fade them in.
			sprite.alpha = 0
			sprite.xScale = 0.5
			sprite.yScale = 0.5
			
			sprite.runAction(
				SKAction.sequence([
					SKAction.waitForDuration(0.25, withRange: 0.5),
					SKAction.group([
						SKAction.fadeInWithDuration(0.25),
						SKAction.scaleTo(1.0, duration: 0.25)
						])
			]))
		}
	}
	
	func addTiles() {
		for row in 0...NumRows {
			for column in 0...NumColumns {
				let topLeft     = (column > 0) && (row < NumRows)
					&& level.tileAtColumn(column - 1, row: row) != nil
				let bottomLeft  = (column > 0) && (row > 0)
					&& level.tileAtColumn(column - 1, row: row - 1) != nil
				let topRight    = (column < NumColumns) && (row < NumRows)
					&& level.tileAtColumn(column, row: row) != nil
				let bottomRight = (column < NumColumns) && (row > 0)
					&& level.tileAtColumn(column, row: row - 1) != nil

				// The tiles are named from 0 to 15, according to the bitmask that is
				// made by combining these four values.
				let value = Int(topLeft) | Int(topRight) << 1 | Int(bottomLeft) << 2 | Int(bottomRight) << 3

				// Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
				if value != 0 && value != 6 && value != 9 {
					let name = String(format: "Tile_%ld", value)
					let tileNode = SKSpriteNode(imageNamed: name)
					var point = pointForColumn(column, row: row)
					point.x -= TileWidth/2
					point.y -= TileHeight/2
					tileNode.position = point
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
		
		playSound(swapSound)
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
		
		playSound(invalidSwapSound)
	}
	
	func animateMatchedSymbols(chains: Set<Chain>, completion: () -> ()) {
		for chain in chains {
			
			animateScoreForChain(chain)
			
			for symbol in chain.symbols {
				if let sprite = symbol.sprite {
					if sprite.actionForKey("removing") == nil {
						let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
						scaleAction.timingMode = .EaseOut
						sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
					}
				}
			}
		}
		playSound(matchSound)
		runAction(SKAction.waitForDuration(0.3), completion: completion)
	}
	
	func animateRemoveSymbols(symbols: Set<Symbol>, completion: () -> ())
	{
		for symbol in symbols {
			if let sprite = symbol.sprite {
				if sprite.actionForKey("removing") == nil {
					let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
					scaleAction.timingMode = .EaseOut
					sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
				}
			}
		}
		//runAction(matchSound)
		runAction(SKAction.waitForDuration(0.3), completion: completion)
	}
	
	func animateFallingSymbols(columns: [[Symbol]], completion: () -> ()) {
		var longestDuration: NSTimeInterval = 0
		for array in columns {
			for (idx, symbol) in enumerate(array) {
				let newPosition = pointForColumn(symbol.column, row: symbol.row)
				let delay = 0.05 + 0.15*NSTimeInterval(idx)
				let sprite = symbol.sprite!
				let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
				longestDuration = max(longestDuration, duration + delay)
				let moveAction = SKAction.moveTo(newPosition, duration: duration)
				moveAction.timingMode = .EaseOut
				if isMuted {
					sprite.runAction(
						SKAction.sequence([
							SKAction.waitForDuration(delay),
							SKAction.group([moveAction])]))
				}
				else {
					sprite.runAction(
						SKAction.sequence([
						SKAction.waitForDuration(delay),
						SKAction.group([moveAction, fallingSymbolSound])]))
				}
			}
		}
		runAction(SKAction.waitForDuration(longestDuration), completion: completion)
	}
	
	func animateNewSymbols(columns: [[Symbol]], completion: () -> ()) {
		var longestDuration: NSTimeInterval = 0
			
		for array in columns {
			
			let startRow = array[0].row + 1

			for (idx, symbol) in enumerate(array) {
				
				let sprite = SKSpriteNode(imageNamed: symbol.symbolType.spriteName)
				sprite.position = pointForColumn(symbol.column, row: startRow)
				symbolsLayer.addChild(sprite)
				symbol.sprite = sprite
				
				let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
				
				let duration = NSTimeInterval(startRow - symbol.row) * 0.1
				longestDuration = max(longestDuration, duration + delay)
				
				let newPosition = pointForColumn(symbol.column, row: symbol.row)
				let moveAction = SKAction.moveTo(newPosition, duration: duration)
				moveAction.timingMode = .EaseOut
				sprite.alpha = 0
				if isMuted {
					sprite.runAction(
						SKAction.sequence([
							SKAction.waitForDuration(delay),
							SKAction.group([
								SKAction.fadeInWithDuration(0.05),
								moveAction])
							]))
				}
				else {
					sprite.runAction(
						SKAction.sequence([
							SKAction.waitForDuration(delay),
							SKAction.group([
								SKAction.fadeInWithDuration(0.05),
								moveAction,
								addSymbolSound])
						]))
				}
			}
		}
		
		runAction(SKAction.waitForDuration(longestDuration), completion: completion)
	}
	
	func animateScoreForChain(chain: Chain) {
		// Figure out what the midpoint of the chain is.
		let firstSprite = chain.firstSymbol().sprite!
		let lastSprite = chain.lastSymbol().sprite!
		let centerPosition = CGPoint(
			x: (firstSprite.position.x + lastSprite.position.x)/2,
			y: (firstSprite.position.y + lastSprite.position.y)/2 - 8
		)
			
		// Add a label for the score that slowly floats up.
		let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
		scoreLabel.fontSize = 16
		scoreLabel.text = NSString(format: "%ld", chain.score)
		scoreLabel.position = centerPosition
		scoreLabel.zPosition = 300
		symbolsLayer.addChild(scoreLabel)
			
		let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
		moveAction.timingMode = .EaseOut
		scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
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
	
	func animateGameOver(completion: () -> ()) {
		let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
		action.timingMode = .EaseIn
		gameLayer.runAction(action, completion: completion)
	}
 
	func animateBeginGame(completion: () -> ()) {
		gameLayer.hidden = false
		gameLayer.position = CGPoint(x: 0, y: size.height)
		let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
		action.timingMode = .EaseOut
		gameLayer.runAction(action, completion: completion)
	}
	
	func animateShowNoSwapsLeft()
	{
		let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.width), duration: 0.3)
		action.timingMode = .EaseIn
		gameLayer.runAction(action)
	}
	
	func removeAllSymbolSprites() {
		symbolsLayer.removeAllChildren()
	}
	
	func noMoves()
	{
		playSound(warningSound)
	}
	
	private func playSound(soundAction: SKAction)
	{
		if !isMuted
		{
			runAction(soundAction)
		}
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
			
			if column < swipeFromColumn! {        // swipe left
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