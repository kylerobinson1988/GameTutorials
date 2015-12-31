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
        
        debugDrawPlayableArea()

    }

    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt * 1000) milliseconds since last update.")

        
        if let lastTouchLocation = lastTouchLocation {
            
            let theDifference = lastTouchLocation - zombie.position
            if theDifference.length() <= zombieMovePointsPerSecond * CGFloat(dt) {
                
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                
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
        print("amount to move: \(amountToMove)")
        
        //2
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        
        let offset = location - zombie.position
    
        let length = offset.length()
        
        let direction = offset / CGFloat(length)
        
        velocity = direction * zombieMovePointsPerSecond
        
    }
    
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
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
        
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0 //1
        let playableHeight = size.width / maxAspectRatio //2
        let playableMargin = (size.height - playableHeight)/2.0 //3
    
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)//4
        super.init(size: size) //5
        
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
























