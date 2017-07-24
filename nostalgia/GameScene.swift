//
//  GameScene.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-01.
//  Copyright © 2016 George Lim. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 {
  case player = 1
  case groundBarrier = 2
  case scoreZone = 4
  case boulder = 8
}

class GameScene: SKScene {
  enum GameScreen {
    case mainMenu, inGame
  }
  
  var pokemon: Pokemon!
  var landscape: Landscape!
  var currentLocation = GameScreen.mainMenu
  
  var isGravityNormal = true {
    didSet {
      let playerNode = childNode(withName: "playerNode") as! PlayerNode
      physicsWorld.gravity = CGVector(dx: 0, dy: 7.848 * playerNode.xScale * (isGravityNormal ? -1 : 1))
    }
  }
  
  override func didMove(to view: SKView) {
    // Setup Trainer data...
    pokemon = Pokemon(model: "latios", shiny: false, nickname: nil, hp: 27, level: 5, exp: 0)
    landscape = Landscape(sceneWidth: size.width, sceneHeight: size.height)
    
    let playerNode = PlayerNode(in: self)
    addChild(playerNode)
    
    let scoreNode = ScoreNode(in: self)
    addChild(scoreNode)
    
    let statusNode = StatusNode(in: self)
    addChild(statusNode)
    
    physicsWorld.contactDelegate = self
    
    drawLandscape()
  }
  
  private func drawLandscape() -> Void {
    backgroundColor = UIColor(hex: "#C6E7FF")
    
    let landscapeNodes = landscape.animatingNodes.count
    let treeOffset = 118 * landscape.spriteScale
    
    for i in 0 ..< landscapeNodes {
      for j in 0 ..< landscape.blocksForAnimation {
        let node = SKSpriteNode(imageNamed: landscape.animatingNodes[i])
        node.name = landscape.animatingNodes[i]
        node.setScale(landscape.spriteScale)
        node.anchorPoint = CGPoint.zero
        node.position.x = landscape.blockWidth * CGFloat(j - 1)
        node.zPosition = CGFloat(i)
        
        if (1 ... 4 ~= i) {
          node.position.y = treeOffset
        }
        
        addChild(node)
      }
    }
    
    let groundBarrier = SKSpriteNode()
    groundBarrier.position = CGPoint(x: size.width / 2, y: landscape.groundHeight)
    
    groundBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
    groundBarrier.physicsBody!.affectedByGravity = false
    groundBarrier.physicsBody!.isDynamic = false
    groundBarrier.physicsBody!.categoryBitMask = PhysicsCategory.groundBarrier.rawValue
    
    addChild(groundBarrier)
  }
  
  private func animateLandscape() -> Void {
    let landscapeNodes = landscape.animatingNodes.count
    for i in 0 ..< landscapeNodes {
      enumerateChildNodes(withName: landscape.animatingNodes[i], using: {
        node, error -> Void in
        let sprite = node as! SKSpriteNode
        if (sprite.position.x >= self.landscape.blockWidth * CGFloat(self.landscape.blocksForAnimation - 1) - 1) {
          sprite.position.x = -self.landscape.blockWidth
        }
        
        sprite.position.x += self.landscape.animatingNodeSpeeds[i]
      })
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Void {
    switch currentLocation {
    case .mainMenu:      
      let delayAction = SKAction.wait(forDuration: 2)
      let spawnerStartAction = Spawner.start(in: self)
      let actionSequence = SKAction.sequence([delayAction, spawnerStartAction])
      
      isGravityNormal = true
      
      let playerNode = childNode(withName: "playerNode") as! PlayerNode
      playerNode.physicsBody!.velocity.dy = 0
      
      let fadeAction = SKAction.fade(in: false, withDuration: 0.5, waitFirst: 0.25)
      
      let statusNode = childNode(withName: "statusNode") as! StatusNode
      statusNode.run(fadeAction)
      
      run(actionSequence)

      currentLocation = .inGame
    case .inGame:
      isGravityNormal = !isGravityNormal
    }
  }
  
  override func update(_ currentTime: TimeInterval) -> Void {
    animateLandscape()
    
    switch currentLocation {
    case .mainMenu:
      break
    default:
      break
    }
  }
  
  override func didSimulatePhysics() {
    let playerNode = childNode(withName: "playerNode") as! PlayerNode
    let statusNode = childNode(withName: "statusNode") as! SKSpriteNode
    statusNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y - (playerNode.size.height + statusNode.size.height) / 2 - 5)
    
    switch currentLocation {
    case .mainMenu:
      if playerNode.physicsBody!.velocity.dy <= -300 {
        playerNode.physicsBody!.velocity.dy = -300
        isGravityNormal = false
      } else if (playerNode.physicsBody!.velocity.dy >= 300) {
        playerNode.physicsBody!.velocity.dy = 300
        isGravityNormal = true
        
        /*
         let delayAction = SKAction.wait(forDuration: 1)
         let updateGravityAction = SKAction.run({
         () in
         playerNode.physicsBody!.affectedByGravity = true
         })
         let actionSequence = SKAction.sequence([delayAction, updateGravityAction])
         run(actionSequence)
         */
      }
    default:
      break
    }
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) -> Void {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    switch contactMask {
    case PhysicsCategory.player.rawValue | PhysicsCategory.boulder.rawValue:
      // new game.
      let playerNode = childNode(withName: "playerNode") as! PlayerNode
      playerNode.physicsBody!.velocity = CGVector.zero
      playerNode.physicsBody!.applyImpulse(CGVector(dx: 128 * landscape.spriteScale, dy: -256 * landscape.spriteScale))
      let angularVelocity = playerNode.physicsBody!.angularVelocity
      playerNode.physicsBody!.angularVelocity = (angularVelocity == 0 ? -15 : angularVelocity * 1.5)
      isGravityNormal = true
      contact.bodyB.categoryBitMask = 0
    case PhysicsCategory.player.rawValue | PhysicsCategory.groundBarrier.rawValue:
      let playerNode = childNode(withName: "playerNode") as! PlayerNode
      playerNode.physicsBody!.velocity.dy = 0
      playerNode.physicsBody!.applyImpulse(CGVector(dx: 128 * landscape.spriteScale, dy: 0))
      isGravityNormal = true
    case PhysicsCategory.player.rawValue | PhysicsCategory.scoreZone.rawValue:
      contact.bodyB.categoryBitMask = 0
      
      let scoreNode = childNode(withName: "scoreNode") as! ScoreNode
      scoreNode.increaseScore()
    default:
      break
    }
  }
}
