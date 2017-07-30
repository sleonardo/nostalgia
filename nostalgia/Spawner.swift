//
//  Spawner.swift
//  nostalgia
//
//  Created by George Lim on 2017-05-07.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

class Spawner {
  
  // Returns the path of a boulder - used for physics collisions.
  static func fetchBoulderPath() -> CGPath {
    let offsetX: CGFloat = 27 / 2
    let offsetY: CGFloat = 30 / 2
    
    let path = CGMutablePath()
    
    path.move(to: CGPoint(x: 0 - offsetX, y: 5 - offsetY))
    path.addLine(to: CGPoint(x: 0 - offsetX, y: 13 - offsetY))
    path.addLine(to: CGPoint(x: 1 - offsetX, y: 17 - offsetY))
    path.addLine(to: CGPoint(x: 2 - offsetX, y: 19 - offsetY))
    path.addLine(to: CGPoint(x: 8 - offsetX, y: 25 - offsetY))
    path.addLine(to: CGPoint(x: 9 - offsetX, y: 27 - offsetY))
    path.addLine(to: CGPoint(x: 11 - offsetX, y: 29 - offsetY))
    path.addLine(to: CGPoint(x: 13 - offsetX, y: 30 - offsetY))
    path.addLine(to: CGPoint(x: 14 - offsetX, y: 30 - offsetY))
    path.addLine(to: CGPoint(x: 18 - offsetX, y: 26 - offsetY))
    path.addLine(to: CGPoint(x: 20 - offsetX, y: 25 - offsetY))
    path.addLine(to: CGPoint(x: 23 - offsetX, y: 22 - offsetY))
    path.addLine(to: CGPoint(x: 24 - offsetX, y: 20 - offsetY))
    path.addLine(to: CGPoint(x: 25 - offsetX, y: 19 - offsetY))
    path.addLine(to: CGPoint(x: 26 - offsetX, y: 17 - offsetY))
    path.addLine(to: CGPoint(x: 27 - offsetX, y: 14 - offsetY))
    path.addLine(to: CGPoint(x: 27 - offsetX, y: 5 - offsetY))
    path.addLine(to: CGPoint(x: 24 - offsetX, y: 2 - offsetY))
    path.addLine(to: CGPoint(x: 22 - offsetX, y: 1 - offsetY))
    path.addLine(to: CGPoint(x: 19 - offsetX, y: 0 - offsetY))
    path.addLine(to: CGPoint(x: 8 - offsetX, y: 0 - offsetY))
    path.addLine(to: CGPoint(x: 5 - offsetX, y: 1 - offsetY))
    path.addLine(to: CGPoint(x: 3 - offsetX, y: 2 - offsetY))
    path.closeSubpath()
    
    return path
  }
  
  // Spawns an indefinite amount of boulder rings.
  static func start(in scene: GameScene) -> SKAction {
    let playerNode = scene.childNode(withName: "playerNode")
    let spriteScale = playerNode!.xScale
    let boulderPath = fetchBoulderPath()
    let ringWidth: CGFloat = 120
    let ringHeight: CGFloat = 192
    let boulderHeight: CGFloat = 30
    let boulderHeightOffset: CGFloat = 3
    let finalX: CGFloat = scene.size.width + ringWidth * spriteScale / 2
    let travelTime: TimeInterval = TimeInterval(finalX * (0.01 - CGFloat(scene.pokemon.level) * 0.000025) / scene.landscape.mapScale)
    let spawnDelay: TimeInterval = travelTime * (0.5 + TimeInterval(scene.pokemon.level) / 600)
    let spawnRadius: CGFloat = scene.size.height - scene.landscape.skyCenter - ringHeight * spriteScale / 2
    
    return .spawnInfinite(delay: spawnDelay, spawn: {
      () in
      let ring: SKSpriteNode = SKSpriteNode(imageNamed: "boulder_ring")
      ring.setScale(spriteScale)
      
      let spawnOffset: CGFloat = CGFloat.random(min: -spawnRadius, max: spawnRadius)
      ring.position = CGPoint(x: -ringWidth * spriteScale / 2, y: scene.landscape.skyCenter + spawnOffset)
      ring.zPosition = 99
      
      let ringOverlay: SKSpriteNode = SKSpriteNode(imageNamed: "boulder_ring_overlay")
      ringOverlay.position = CGPoint(x: -(ringWidth - ringOverlay.size.width) / 2, y: -1)
      ringOverlay.zPosition = 2
      
      let upperBarrier: SKSpriteNode = SKSpriteNode()
      upperBarrier.position.y = (ringHeight - boulderHeight - boulderHeightOffset) / 2
      
      upperBarrier.physicsBody = SKPhysicsBody(polygonFrom: boulderPath)
      upperBarrier.physicsBody!.affectedByGravity = false
      upperBarrier.physicsBody!.isDynamic = false
      upperBarrier.physicsBody!.categoryBitMask = PhysicsCategory.boulder.rawValue
      
      let scoreZone: SKSpriteNode = SKSpriteNode()
      scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: ringHeight - boulderHeight * 2))
      scoreZone.physicsBody!.affectedByGravity = false
      scoreZone.physicsBody!.isDynamic = false
      scoreZone.physicsBody!.categoryBitMask = PhysicsCategory.scoreZone.rawValue
      
      let lowerBarrier: SKSpriteNode = SKSpriteNode()
      lowerBarrier.position.y = -(ringHeight - boulderHeight - boulderHeightOffset) / 2
      
      lowerBarrier.physicsBody = SKPhysicsBody(polygonFrom: boulderPath)
      lowerBarrier.physicsBody!.affectedByGravity = false
      lowerBarrier.physicsBody!.isDynamic = false
      lowerBarrier.physicsBody!.categoryBitMask = PhysicsCategory.boulder.rawValue
      
      ring.addChild(ringOverlay)
      ring.addChild(upperBarrier)
      ring.addChild(scoreZone)
      ring.addChild(lowerBarrier)
      
      scene.addChild(ring)
      
      ring.run(.moveTo(x: finalX, withDuration: travelTime, remove: true))
    })
  }
}
