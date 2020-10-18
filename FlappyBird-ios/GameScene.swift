//
//  GameScene.swift
//  FlappyBird-ios
//
//  Created by Wei Lun Hsu on 2020/10/10.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let pipeGap = 150.0
    var bird = SKSpriteNode()
    var pipeUpTexture = SKTexture()
    var pipeDownTexture = SKTexture()
    var pipeMoveAndRemove = SKAction()
    var scoreLabelNode = SKLabelNode()
    var score = Int()
    var moving = SKNode()
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    override func didMove(to view: SKView) {
        // Get label node from scene and store it for use later
        
        // 啟用物理世界 - 設定重力
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        
        // 碰撞 Delegate
        self.physicsWorld.contactDelegate = self
        // set moving
        self.addChild(moving)
        
        // Ground
        let groundTexture = SKTexture(imageNamed: "land.png")
        groundTexture.filteringMode = .nearest // 最近點取樣
        
        let groundDistanceMove = CGFloat(groundTexture.size().width * 2.0)
        let moveGroundSprite = SKAction.moveBy(x: -groundDistanceMove, y: 0, duration: TimeInterval(0.02 * groundDistanceMove))
        let resetGroundSprite = SKAction.moveBy(x: groundDistanceMove, y: 0, duration: 0.0)
        let moveGroundSpriteForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (groundTexture.size().width * 2)){
            let i = CGFloat(i)
            let groundSprite = SKSpriteNode(texture: groundTexture)
            groundSprite.setScale(2.0)
            groundSprite.position = CGPoint(x: i * groundSprite.size.width, y: self.frame.size.height / -2 + (groundTexture.size().height / 2))
            groundSprite.run(moveGroundSpriteForever)
            moving.addChild(groundSprite)
        }
        
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: self.frame.size.height / -2 + (groundTexture.size().height / 2))
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: groundTexture.size().height * 2.0))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        
        self.addChild(ground)
        
/*
        // Ground
        let groundTexture = SKTexture(imageNamed: "land.png")
        let groundSprite = SKSpriteNode(texture: groundTexture)
        groundSprite.setScale(2.0)
        groundSprite.position = CGPoint(x: 0, y:  self.frame.size.height / -2 + (groundTexture.size().height / 2))
        
        self.addChild(groundSprite)
        
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: self.frame.size.height / -2 + (groundTexture.size().height / 2))
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: groundTexture.size().height * 1.8))
        ground.physicsBody?.isDynamic = false
        
        self.addChild(ground)
 */
        
        // Bird
        let birdTexture = SKTexture(imageNamed: "bird-01.png")
        birdTexture.filteringMode = .nearest
        let birdTexture2 = SKTexture(imageNamed: "bird-02.png")
        birdTexture2.filteringMode = .nearest
        
        // 增加動畫效果
        let anim = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.2)
        let animForever = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.setScale(2.0)
        bird.position = CGPoint(x: 0, y: 0)
        bird.run(animForever)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(bird)
        
/*
        let birdTexture1 = SKTexture(imageNamed: "bird-01")
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(imageNamed: "bird-02")
        birdTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPoint(x: self.frame.size.width * 0.35, y:self.frame.size.height * 0.6)
        bird.run(flap)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
*/
        // Pipes
        pipeUpTexture = SKTexture(imageNamed: "PipeUp.png")
        pipeDownTexture = SKTexture(imageNamed: "PipeDown.png")
        
        // move pipes
        let distanceMove = CGFloat(self.frame.size.width * 2 + 2 * pipeUpTexture.size().width)
        let movePipes = SKAction.moveBy(x: -distanceMove, y: 0.0, duration: TimeInterval(0.01 * distanceMove))
        let removePipes = SKAction.removeFromParent()
        pipeMoveAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn pipes (產出 pipes)
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayFor = SKAction.repeatForever(spawnThenDelay)
        
        self.run(spawnThenDelayFor)
        
        // Initialize label and create a label which holds the score
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPoint(x: 0 ,y: 0)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
    
/*
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
 */
    }
    
    func spawnPipes(){
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: self.frame.size.width + pipeUpTexture.size().width * 2, y: -self.frame.size.height / 2 + (pipePair.frame.size.height / 2))
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height / 4)
        let y = Double(arc4random_uniform(height) + height)
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPoint(x: 0.0, y: y + Double(pipeDown.size.height) + pipeGap)
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPoint(x: 0.0, y: y)
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
        
        // 計分
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: pipeDown.size.width + bird.size.width / 2, y: self.frame.size.height / 2 )
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.frame.size.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        pipePair.run(pipeMoveAndRemove)
        self.addChild(pipePair)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for _ in touches{
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK:- SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
            // 得分
            score += 1
            scoreLabelNode.text = String(score)
            
            // 計分Label的動畫
            scoreLabelNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: TimeInterval(0.1)), SKAction.scale(to: 1.0, duration: TimeInterval(0.1))]))
        }else{
            // Game Over
            print("Gameover")
        }
    }
}
