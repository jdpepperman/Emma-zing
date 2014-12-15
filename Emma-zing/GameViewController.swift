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
	
	var currentLevel = 0 //last level -1
	let finalLevel = 32
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	var defaults = NSUserDefaults.standardUserDefaults()
	
	lazy var backgroundMusic: AVAudioPlayer = {
		let url = NSBundle.mainBundle().URLForResource("GlassForEmmaSoft", withExtension: "mp3")
		let player = AVAudioPlayer(contentsOfURL: url, error: nil)
		player.numberOfLoops = -1
		return player
	}()
	
	
	@IBOutlet weak var overallScoreTextLabel: UILabel!
	@IBOutlet weak var overallScoreLabel: UILabel!
 
	@IBOutlet weak var targetTextLabel: UILabel!
	@IBOutlet weak var targetLabel: UILabel!
	@IBOutlet weak var movesTextLabel: UILabel!
	@IBOutlet weak var movesLabel: UILabel!
	@IBOutlet weak var scoreTextLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	
	@IBOutlet weak var levelTextLabel: UILabel!
	@IBOutlet weak var levelLabel: UILabel!
	@IBOutlet weak var finalScoreTextLabel: UILabel!
	@IBOutlet weak var finalScoreLabel: UILabel!
	@IBOutlet weak var highScoreTextLabel: UILabel!
	@IBOutlet weak var highScoreLabel: UILabel!
	@IBOutlet weak var playAgainButton: UIButton!
	@IBAction func playAgainButtonPressed(AnyObject) {
		overallScoreTextLabel.hidden = false
		overallScoreLabel.hidden = false
		targetTextLabel.hidden = false
		targetLabel.hidden = false
		movesTextLabel.hidden = false
		movesLabel.hidden = false
		scoreTextLabel.hidden = false
		scoreLabel.hidden = false
		levelTextLabel.hidden = false
		levelLabel.hidden = false
		noMovesWarningPanel.hidden = false
		
		finalScoreTextLabel.hidden = true
		finalScoreLabel.hidden = true
		highScoreTextLabel.hidden = true
		highScoreLabel.hidden = true
		playAgainButton.hidden = true
		
		//currentLevel = 0
		defaults.setInteger(0, forKey: "currentLevel")
		score = 0
		//overallScore = 0
		defaults.setInteger(0, forKey: "overallScore")
		
		reset()
		beginGame()
	}
	
	@IBOutlet weak var gameOverPanel: UIImageView!
	@IBOutlet weak var noMovesWarningPanel: UIImageView!
	
	@IBOutlet weak var shuffleButton: UIButton!
	@IBAction func shuffleButtonPressed(AnyObject) {
		shuffle()
		decrementMoves()
	}
	
	@IBOutlet weak var toggleSoundButton: UIButton!
	@IBAction func toggleSoundButtonPressed(AnyObject) {
		scene.isMuted = !scene.isMuted
		defaults.setBool(scene.isMuted, forKey: "soundEffects")
		
		if scene.isMuted
		{
			backgroundMusic.stop()
			toggleSoundButtonTexture()
		}
		else
		{
			backgroundMusic.play()
			toggleSoundButtonTexture()
		}
	}
	
	private func toggleSoundButtonTexture()
	{
		let soundOnImage: UIImage = UIImage(named: "TurnSoundOnButton")!
		let soundOffImage: UIImage = UIImage(named: "TurnSoundOffButton")!
		if scene.isMuted
		{
			toggleSoundButton.setImage(soundOnImage, forState: UIControlState.Normal)
		}
		else
		{
			toggleSoundButton.setImage(soundOffImage, forState: UIControlState.Normal)
		}
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
		
		var prevMuteSelection:Bool? = defaults.boolForKey("soundEffects")
		if scene != nil
		{
			prevMuteSelection = scene.isMuted
		}
		
		
		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFill
		
		//currentLevel = defaults.integerForKey("currentLevel")
		defaults.setInteger(defaults.integerForKey("currentLevel"), forKey: "currentLevel")
		
		level = Level(filename: "Level_" + String(defaults.integerForKey("currentLevel")))
		//level = Level(filename: "Level_" + String(currentLevel))
		
		scene.level = level
		
		scene.addTiles()
		
		scene.swipeHandler = handleSwipe
		
		gameOverPanel.hidden = true
		shuffleButton.hidden = true
		noMovesWarningPanel.hidden = true
		
		if prevMuteSelection != nil
		{
			scene.isMuted = prevMuteSelection!
		}
		toggleSoundButtonTexture()
		
		// Present the scene.
		skView.presentScene(scene)
		
		if !scene.isMuted
		{
			backgroundMusic.play()
		}
	}
	
	func beginGame() {
		//currentLevel++
		//defaults.setInteger(currentLevel, forKey: "currentLevel")
		defaults.setInteger(defaults.integerForKey("currentLevel")+1, forKey: "currentLevel")
		
		//defaults.setInteger(overallScore, forKey: "overallScore")
		var temp = defaults.integerForKey("overallScore")
		if defaults.integerForKey("overallScore") > 0
		{
			overallScore = defaults.integerForKey("overallScore")
		}
		reset()
		
		movesLeft = level.maximumMoves
		
		score = 0
		updateLabels()
		
		level.resetComboMultiplier()
		
		scene.animateBeginGame() {
			self.shuffleButton.hidden = false
			self.noMovesWarningPanel.hidden = true
		}
		
		shuffle()
	}
	
	func endGame()
	{
		finalScoreLabel.text = String(overallScore)
		var highScore: Int = defaults.integerForKey("highScore")
		highScoreLabel.text = String(highScore)
		if overallScore > highScore
		{
			defaults.setInteger(overallScore, forKey: "highScore")
		}
		
		overallScoreTextLabel.hidden = true
		overallScoreLabel.hidden = true
		targetTextLabel.hidden = true
		targetLabel.hidden = true
		movesTextLabel.hidden = true
		movesLabel.hidden = true
		scoreTextLabel.hidden = true
		scoreLabel.hidden = true
		levelTextLabel.hidden = true
		levelLabel.hidden = true
		noMovesWarningPanel.hidden = true
		
		finalScoreTextLabel.hidden = false
		finalScoreLabel.hidden = false
		highScoreTextLabel.hidden = false
		highScoreLabel.hidden = false
		playAgainButton.hidden = false
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
		levelLabel.text = NSString(format: "%ld", defaults.integerForKey("currentLevel"))
	}
	
	func decrementMoves() {
		if movesLeft > 0 { --movesLeft }
		updateLabels()
		
		if movesLeft == 0 && level.targetScore > score
		{
			gameOverPanel.image = UIImage(named: "GameOver")
			
			var scoreToLose = level.targetScore/10 * level.maximumMoves
			overallScore -= scoreToLose
			
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
		
		//add the value of 1 match for each move left
		score += symbols.count*32
		overallScore += symbols.count*32
		
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
		if level.getNumPossibleSwaps() == 0 && score < level.targetScore
		{
			scene.noMoves()
			noMovesWarningPanel.hidden = false
		}
		else
		{
			noMovesWarningPanel.hidden = true
		}
	}
	
	func showGameOver() {
		noMovesWarningPanel.hidden = true
		gameOverPanel.hidden = false
		scene.userInteractionEnabled = false
		shuffleButton.hidden = true
		
		defaults.setInteger(overallScore, forKey: "overallScore")
			
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
		if defaults.integerForKey("currentLevel") >= finalLevel
		{
			endGame()
		}
		else
		{
			beginGame()
		}
	}
	
	func checkScore()
	{
		if overallScore == 3232 || overallScore == 323232
		{
			overallScoreLabel.textColor = UIColor.redColor()
		}
		else
		{
			overallScoreLabel.textColor = UIColor.cyanColor()
		}
	}
}