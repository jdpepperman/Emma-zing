//
//  GameViewController.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/24/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
	var level: Level!
	var scene: GameScene!
 
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
 
	override func shouldAutorotate() -> Bool {
		return true
	}
 
	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
	}
 
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Configure the view.
		let skView = view as SKView
		skView.multipleTouchEnabled = false
		
		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFill
		
		level = Level(filename: "Level_1")
		scene.level = level
		
		scene.addTiles()
		
		scene.swipeHandler = handleSwipe
		
		// Present the scene.
		skView.presentScene(scene)
		
		beginGame()
	}
	
	func beginGame() {
		shuffle()
	}
 
	func shuffle() {
		let newSymbols = level.shuffle()
		scene.addSpritesForSymbols(newSymbols)
	}
	
	func handleSwipe(swap: Swap) {
		view.userInteractionEnabled = false
			
		if level.isPossibleSwap(swap) {
			level.performSwap(swap)
			scene.animateSwap(swap) {
				self.view.userInteractionEnabled = true
			}
		}
		else
		{
			scene.animateInvalidSwap(swap) {
				self.view.userInteractionEnabled = true
			}
		}
	}
}