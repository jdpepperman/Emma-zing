//
//  GameViewController.swift
//  Emma-zing
//
//  Created by Joshua Pepperman on 11/24/14.
//  Copyright (c) 2014 Joshua Pepperman. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
	var level: Level!
	var scene: GameScene!
	
	var overallScore = 0
	
	var movesLeft = 0
	var score = 0
	
	var currentLevel = 0
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	lazy var backgroundMusic: AVAudioPlayer = {
		let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
		let player = AVAudioPlayer(contentsOfURL: url, error: nil)
		player.numberOfLoops = -1
		return player
	}()
	
	@IBOutlet weak var overallScoreLabel: UILabel!
 
	@IBOutlet weak var targetLabel: UILabel!
	@IBOutlet weak var movesLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	
	@IBOutlet weak var gameOverPanel: UIImageView!
	@IBOutlet weak var noMovesWarningPanel: UIImageView!
	
	@IBOutlet weak var shuffleButton: UIButton!
	@IBAction func shuffleButtonPressed(AnyObject) {
		shuffle()
		decrementMoves()
	}
 
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
		
		reset()
		
		beginGame()
	}
	
	func reset()
	{
		// Configure the view.
		let skView = view as SKView
		skView.multipleTouchEnabled = false
		
		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFill
		
		level = Level(filename: "Level_" + String(currentLevel))
		scene.level = level
		
		scene.addTiles()
		
		scene.swipeHandler = handleSwipe
		
		gameOverPanel.hidden = true
		shuffleButton.hidden = true
		noMovesWarningPanel.hidden = true
		
		// Present the scene.
		skView.presentScene(scene)
		
		backgroundMusic.play()
		
	}
	
	func beginGame() {
		reset()
		currentLevel++
		movesLeft = level.maximumMoves
		score = 0
		updateLabels()
		
		level.resetComboMultiplier()
		
		scene.animateBeginGame() {
			self.shuffleButton.hidden = false
		}
		
		shuffle()
	}
 
	func shuffle() {
		scene.removeAllSymbolSprites()
		
		let newSymbols = level.shuffle()
		scene.addSpritesForSymbols(newSymbols)
		
		noMovesWarningPanel.hidden = true
	}
	
	func updateLabels() {
		targetLabel.text = NSString(format: "%ld", level.targetScore)
		movesLabel.text = NSString(format: "%ld", movesLeft)
		scoreLabel.text = NSString(format: "%ld", score)
		overallScoreLabel.text = NSString(format: "%ld", overallScore)
	}
	
	func decrementMoves() {
		if movesLeft > 0 { --movesLeft }
		updateLabels()
		
		if movesLeft == 0 && level.targetScore > score
		{
			gameOverPanel.image = UIImage(named: "GameOver")
			showGameOver()
		}
		else if score >= level.targetScore && movesLeft > 0
		{
			view.userInteractionEnabled = false
			handleExtraMoves()
			movesLeft = 0
		}
		else if movesLeft <= 0
		{
			gameOverPanel.image = UIImage(named: "LevelComplete")
			showGameOver()
		}
	}
	
	func handleSwipe(swap: Swap) {
		view.userInteractionEnabled = false
		
		if level.isPossibleSwap(swap) {
			level.performSwap(swap)
			scene.animateSwap(swap, completion: handleMatches)
		}
		else
		{
			scene.animateInvalidSwap(swap) {
				self.view.userInteractionEnabled = true
			}
		}
	}
	
	func handleMatches() {
		let chains = level.removeMatches()
		
		if chains.count == 0 {
			beginNextTurn()
			return
		}
		
		scene.animateMatchedSymbols(chains) {
			//update the score
			for chain in chains {
				self.score += chain.score
				self.overallScore += chain.score
			}
			self.updateLabels()
			
			//fill up the empty spots
			let columns = self.level.fillHoles()
			self.scene.animateFallingSymbols(columns) {
				let columns = self.level.topUpSymbols()
				self.scene.animateNewSymbols(columns) {
					self.handleMatches()
				}
			}
		}
	}
	
	func handleExtraMoves()
	{
		let symbols = level.removeRandomSymbols(movesLeft)
		
		if symbols.count == 0
		{
			return
		}
		
		scene.animateRemoveSymbols(symbols)
		{
			//fill up the empty spots
			let columns = self.level.fillHoles()
			self.scene.animateFallingSymbols(columns) {
				let columns = self.level.topUpSymbols()
				self.scene.animateNewSymbols(columns) {
					self.handleMatches()
				}
			}
		}
	}
	
	func beginNextTurn() {
		level.resetComboMultiplier()
		
		level.detectPossibleSwaps()
		view.userInteractionEnabled = true
		
		
		
		decrementMoves()
		println("Moves left: \(level.getNumPossibleSwaps())")
		
		checkScore()
		
		//check for no moves
		if level.getNumPossibleSwaps() == 0
		{
			noMovesWarningPanel.hidden = false
		}
		else
		{
			noMovesWarningPanel.hidden = true
		}
	}
	
	func showGameOver() {
		gameOverPanel.hidden = false
		scene.userInteractionEnabled = false
		shuffleButton.hidden = true
		noMovesWarningPanel.hidden = true
			
		scene.animateGameOver() {
			self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
			self.view.addGestureRecognizer(self.tapGestureRecognizer)
		}
	}
	
	func hideGameOver() {
		view.removeGestureRecognizer(tapGestureRecognizer)
		tapGestureRecognizer = nil
		
		gameOverPanel.hidden = true
		scene.userInteractionEnabled = true
		
		//if there are no more levels, show high score, otherwise begin next level
		beginGame()
	}
	
	func checkScore()
	{
		if overallScore == 3232
		{
			overallScoreLabel.textColor = UIColor.redColor()
		}
		else
		{
			overallScoreLabel.textColor = UIColor.cyanColor()
		}
	}
}