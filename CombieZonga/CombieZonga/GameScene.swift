//
//  GameScene.swift
//  CombieZonga
//
//  Created by Kyle Brooks Robinson on 12/26/15.
//  Copyright (c) 2015 Kyle Brooks Robinson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "background1")
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieAnimation: SKAction
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0

    let zombieMovePointsPerSecond: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    let playableRect: CGRect
    
    var lastTouchLocation: CGPoint?
    
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π

    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        
        /*let zombieSize = zombie.size
        print("The zombie's size is \(zombieSize)")
        zombie.size = CGSize(width: zombieSize.width * 2, height: zombieSize.height * 2)*/
        
        addChild(zombie)

        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy), SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        
        debugDrawPlayableArea()

    }

    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
//        print("\(dt * 1000) milliseconds since last update.")

        
        if let lastTouchLocation = lastTouchLocation {
            
            let theDifference = lastTouchLocation - zombie.position
            if theDifference.length() <= zombieMovePointsPerSecond * CGFloat(dt) {
                
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                stopZombieAnimation()
                
            } else {
                
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
                
            }
            
            boundsCheckZombie()
            
        }
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        //1
        let amountToMove = velocity * CGFloat(dt)
//        print("amount to move: \(amountToMove)")
        
        //2
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        
        startZombieAnimation()
        
        let offset = location - zombie.position
    
        let length = offset.length()
        
        let direction = offset / CGFloat(length)
        
        velocity = direction * zombieMovePointsPerSecond
        
    }
    
    // Touch Methods
    
    func sceneTouched(touchLocation: CGPoint) {
        
        moveZombieToward(touchLocation)
        lastTouchLocation = touchLocation
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
        
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
        
    }
    
    // Sprite Methods
    
    func boundsCheckZombie() {
        
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
        
    }
    
    func spawnEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 4.0)
        
        /*let actionMidMove = SKAction.moveByX(-size.width/2-enemy.size.width/2, y: -CGRectGetHeight(playableRect)/2 + enemy.size.height/2, duration: 2.0)
        let actionMove = SKAction.moveByX(-size.width/2-enemy.size.width/2, y: CGRectGetHeight(playableRect)/2 - enemy.size.height, duration: 2.0)
        let wait = SKAction.waitForDuration(0.25)
        let logMessage = SKAction.runBlock() {
            print("Reached bottom!")
        }
        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
        
        let repeatAction = SKAction.repeatActionForever(sequence)*/
        
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
        
//        let actionMove = SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration: 2.0)
//        enemy.runAction(actionMove)
        
    }
    
    func spawnCat() {
        
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)
            ))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration:  0.5)

        cat.zRotation = -π / 16
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])

        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
        
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
    }
    
    func checkCollisions() {
        
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(
                CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }

            
        }
        
        
    }
    
    
    // Helper Methods
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
        
    }
    
    func startZombieAnimation() {
        
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
        
    }
    
    func stopZombieAnimation() {
        
        zombie.removeActionForKey("animation")
        
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0 //1
        let playableHeight = size.width / maxAspectRatio //2
        let playableMargin = (size.height - playableHeight)/2.0 //3
    
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)//4
        
        var textures: [SKTexture] = []
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        super.init(size: size)
        
    }
    
    required init(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented") //6
    }
    
    func debugDrawPlayableArea() {
        
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
        
    }
    
    
    
}
























