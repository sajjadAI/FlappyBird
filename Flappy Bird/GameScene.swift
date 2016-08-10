//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Sajjad Aboutalebi on 8/10/16.
//  Copyright (c) 2016 Sajjad Aboutalebi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var backGround = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var gameOver = false
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var pauseButton = SKSpriteNode()
    var pausedStat = false
    var PauseLabel = SKSpriteNode()
    var timer = NSTimer()
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    func initialize() {
        self.setUpBackGround()
        self.setUpGround()
        self.setUpRoof()
        self.setUpScoreLabel()
        self.setUpBird()
        self.showPaseButton()
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.setUpPipes), userInfo: nil, repeats: true)
        
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        initialize()
        

    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if pausedStat == true {
            pausedStat = false
            self.paused = false
            self.speed = 1
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.setUpPipes), userInfo: nil, repeats: true)
            self.removeChildrenInArray([PauseLabel])
        }
        if gameOver == false {
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 50))
        } else {
            timer.invalidate()
            bird.physicsBody!.allowsRotation = false
            score = 0
            scoreLabel.text = "0"
            self.removeAllChildren()
            initialize()
            gameOver = false
            self.speed = 1
            bird.physicsBody!.allowsRotation = true
        }
    }
   
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if pauseButton.containsPoint(location){
                if pausedStat == false {
                    self.paused = true
                    pausedStat = true
                    self.speed = 0
                    timer.invalidate()
                    self.addChild(self.showPauseLabel())
                }else {
                    pausedStat = false
                    self.paused = false
                    self.speed = 1
                    timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.setUpPipes), userInfo: nil, repeats: true)
                    self.removeChildrenInArray([PauseLabel])
                }
            }
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
            scoreLabel.text = String(score)
        }else {
            if gameOver == false {
                gameOver = true
                self.speed = 0
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap To Play Again"
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameOverLabel.zPosition = 4
                self.addChild(gameOverLabel)
            }
           
        }
       
        
    }
    func showPauseLabel() -> SKSpriteNode {
        let pauseLabelTexture = SKTexture(imageNamed: "Paused .png")
        PauseLabel = SKSpriteNode(texture: pauseLabelTexture)
        PauseLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        PauseLabel.zPosition = 4
        return PauseLabel
    }
    
    func showPaseButton() {
        let pauseButtonTexture = SKTexture(imageNamed: "2.png")
        pauseButton = SKSpriteNode(texture: pauseButtonTexture)
        pauseButton.position = CGPoint(x: self.frame.size.width/2 + self.frame.size.width/5.7, y: self.frame.size.height - 38)
        pauseButton.zPosition = 4
        self.addChild(pauseButton)
    }
    
    
    
    func setUpScoreLabel() {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 4
        addChild(scoreLabel)
    }
    
    func setUpBackGround() {
        let bgTexture = SKTexture(imageNamed: "bg.png")
        backGround = SKSpriteNode(texture: bgTexture)
        backGround.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        backGround.zPosition = 1
        backGround.size.height = self.frame.height
        let moveBG = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBG = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBGanimation = SKAction.repeatActionForever(SKAction.sequence([moveBG, replaceBG]))
        for var i: CGFloat = 0; i < 2; i++ {
            backGround = SKSpriteNode(texture: bgTexture)
            backGround.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: CGRectGetMidY(self.frame))
            backGround.size.height = self.frame.height
            backGround.runAction(moveBGanimation)
            addChild(backGround)
        }
    }
    
    
    func setUpBird() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.11)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.zPosition = 3
        bird.runAction(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(bird)
    }
    
    func setUpGround() {
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody!.dynamic = false
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
    }
    func setUpRoof() {
        let roof = SKNode()
        roof.position = CGPointMake(0, self.frame.size.height)
        roof.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        roof.physicsBody!.dynamic = false
        self.addChild(roof)
    }
    
    
    func setUpPipes() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let gapHeight = birdTexture.size().height * 3
        
        var movementAmount = -self.frame.size.height + CGFloat(arc4random_uniform(UInt32(self.frame.size.height + self.frame.size.height) + 1))
        var pipeOffset: CGFloat
        if movementAmount > 0 {
            while movementAmount >= self.frame.size.height/3 {
                movementAmount = movementAmount - 30
            }
            
        }else {
            while movementAmount <= -self.frame.size.height/3 {
                movementAmount = movementAmount + 30
            }
        }
        pipeOffset = movementAmount
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.zPosition = 2
        pipe1.runAction(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody!.dynamic = false
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(pipe1)
        let pipe2Texture = SKTexture(imageNamed: "pipe2")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.zPosition = 2
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2Texture.size())
        pipe2.physicsBody!.dynamic = false
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width + 10, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width - 10, gapHeight))
        gap.physicsBody!.dynamic = false
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
        
    }

}

















