//
//  PlayerNode.swift
//  nostalgia
//
//  Created by George Lim on 2017-05-08.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

class PlayerNode: SKSpriteNode {
  
  override init(texture: SKTexture!, color: SKColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  convenience init(in scene: GameScene) {
    var textureName = "pokemon_\(scene.pokemon.model)"
    
    if (scene.pokemon.shiny) {
      textureName += "_shiny"
    }
    
    self.init(imageNamed: textureName)
    
    name = "playerNode"
    setScale(scene.landscape.spriteScale * (0.9 + CGFloat(scene.pokemon.level) * 0.001))
    position = CGPoint(x: scene.size.width / 2, y: scene.landscape.skyCenter + size.height)
    zPosition = 100
    
    let pokemonPath = fetchPath(model: scene.pokemon.model, size: xScale)
    
    physicsBody = SKPhysicsBody(polygonFrom: pokemonPath)
    physicsBody!.isDynamic = true
    physicsBody!.categoryBitMask = PhysicsCategory.player.rawValue
    physicsBody!.collisionBitMask = PhysicsCategory.groundBarrier.rawValue | PhysicsCategory.boulder.rawValue
    physicsBody!.contactTestBitMask = PhysicsCategory.groundBarrier.rawValue | PhysicsCategory.boulder.rawValue | PhysicsCategory.scoreZone.rawValue
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Returns the path of the player pokemon model - used for physics collisions.
  private func fetchPath(model: String, size: CGFloat = 1) -> CGPath {
    let path = CGMutablePath()
    var offsetX: CGFloat
    var offsetY: CGFloat
    
    switch model {
    case "latias":
      offsetX = 85 * size / 2
      offsetY = 43 * size / 2
      
      path.move(to: CGPoint(x: 0 * size - offsetX, y: 17 * size - offsetY))
      path.addLine(to: CGPoint(x: 0 * size - offsetX, y: 18 * size - offsetY))
      path.addLine(to: CGPoint(x: 2 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 6 * size - offsetX, y: 26 * size - offsetY))
      path.addLine(to: CGPoint(x: 8 * size - offsetX, y: 30 * size - offsetY))
      path.addLine(to: CGPoint(x: 9 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 10 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 10 * size - offsetX, y: 28 * size - offsetY))
      path.addLine(to: CGPoint(x: 11 * size - offsetX, y: 28 * size - offsetY))
      path.addLine(to: CGPoint(x: 14 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 16 * size - offsetX, y: 32 * size - offsetY))
      path.addLine(to: CGPoint(x: 17 * size - offsetX, y: 32 * size - offsetY))
      path.addLine(to: CGPoint(x: 17 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 18 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 16 * size - offsetX, y: 27 * size - offsetY))
      path.addLine(to: CGPoint(x: 15 * size - offsetX, y: 27 * size - offsetY))
      path.addLine(to: CGPoint(x: 15 * size - offsetX, y: 24 * size - offsetY))
      path.addLine(to: CGPoint(x: 16 * size - offsetX, y: 23 * size - offsetY))
      path.addLine(to: CGPoint(x: 31 * size - offsetX, y: 19 * size - offsetY))
      path.addLine(to: CGPoint(x: 37 * size - offsetX, y: 19 * size - offsetY))
      path.addLine(to: CGPoint(x: 37 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 39 * size - offsetX, y: 21 * size - offsetY))
      path.addLine(to: CGPoint(x: 42 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 44 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 57 * size - offsetX, y: 40 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 40 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 60 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 61 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 60 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 34 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 29 * size - offsetY))
      path.addLine(to: CGPoint(x: 59 * size - offsetX, y: 29 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 42 * size - offsetY))
      path.addLine(to: CGPoint(x: 79 * size - offsetX, y: 42 * size - offsetY))
      path.addLine(to: CGPoint(x: 79 * size - offsetX, y: 41 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 40 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 39 * size - offsetY))
      path.addLine(to: CGPoint(x: 80 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 81 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 75 * size - offsetX, y: 34 * size - offsetY))
      path.addLine(to: CGPoint(x: 72 * size - offsetX, y: 31 * size - offsetY))
      path.addLine(to: CGPoint(x: 71 * size - offsetX, y: 29 * size - offsetY))
      path.addLine(to: CGPoint(x: 67 * size - offsetX, y: 23 * size - offsetY))
      path.addLine(to: CGPoint(x: 65 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 68 * size - offsetX, y: 17 * size - offsetY))
      path.addLine(to: CGPoint(x: 70 * size - offsetX, y: 17 * size - offsetY))
      path.addLine(to: CGPoint(x: 72 * size - offsetX, y: 16 * size - offsetY))
      path.addLine(to: CGPoint(x: 72 * size - offsetX, y: 15 * size - offsetY))
      path.addLine(to: CGPoint(x: 71 * size - offsetX, y: 14 * size - offsetY))
      path.addLine(to: CGPoint(x: 72 * size - offsetX, y: 13 * size - offsetY))
      path.addLine(to: CGPoint(x: 84 * size - offsetX, y: 7 * size - offsetY))
      path.addLine(to: CGPoint(x: 84 * size - offsetX, y: 6 * size - offsetY))
      path.addLine(to: CGPoint(x: 82 * size - offsetX, y: 6 * size - offsetY))
      path.addLine(to: CGPoint(x: 82 * size - offsetX, y: 4 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 6 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 5 * size - offsetY))
      path.addLine(to: CGPoint(x: 80 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 80 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 0 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 0 * size - offsetY))
      path.addLine(to: CGPoint(x: 74 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 73 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 72 * size - offsetX, y: 4 * size - offsetY))
      path.addLine(to: CGPoint(x: 71 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 69 * size - offsetX, y: 1 * size - offsetY))
      path.addLine(to: CGPoint(x: 66 * size - offsetX, y: 7 * size - offsetY))
      path.addLine(to: CGPoint(x: 64 * size - offsetX, y: 5 * size - offsetY))
      path.addLine(to: CGPoint(x: 58 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 54 * size - offsetX, y: 1 * size - offsetY))
      path.addLine(to: CGPoint(x: 50 * size - offsetX, y: 1 * size - offsetY))
      path.addLine(to: CGPoint(x: 45 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 39 * size - offsetX, y: 4 * size - offsetY))
      path.addLine(to: CGPoint(x: 35 * size - offsetX, y: 6 * size - offsetY))
      path.addLine(to: CGPoint(x: 32 * size - offsetX, y: 9 * size - offsetY))
      path.addLine(to: CGPoint(x: 16 * size - offsetX, y: 13 * size - offsetY))
      path.addLine(to: CGPoint(x: 11 * size - offsetX, y: 14 * size - offsetY))
      path.addLine(to: CGPoint(x: 4 * size - offsetX, y: 15 * size - offsetY))
      path.addLine(to: CGPoint(x: 1 * size - offsetX, y: 16 * size - offsetY))
      
    default:
      offsetX = 104 * size / 2
      offsetY = 56 * size / 2
      
      path.move(to: CGPoint(x: 0 * size - offsetX, y: 21 * size - offsetY))
      path.addLine(to: CGPoint(x: 0 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 1 * size - offsetX, y: 24 * size - offsetY))
      path.addLine(to: CGPoint(x: 5 * size - offsetX, y: 28 * size - offsetY))
      path.addLine(to: CGPoint(x: 7 * size - offsetX, y: 29 * size - offsetY))
      path.addLine(to: CGPoint(x: 10 * size - offsetX, y: 30 * size - offsetY))
      path.addLine(to: CGPoint(x: 11 * size - offsetX, y: 32 * size - offsetY))
      path.addLine(to: CGPoint(x: 12 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 13 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 14 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 16 * size - offsetX, y: 36 * size - offsetY))
      path.addLine(to: CGPoint(x: 17 * size - offsetX, y: 36 * size - offsetY))
      path.addLine(to: CGPoint(x: 20 * size - offsetX, y: 39 * size - offsetY))
      path.addLine(to: CGPoint(x: 21 * size - offsetX, y: 39 * size - offsetY))
      path.addLine(to: CGPoint(x: 21 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 23 * size - offsetX, y: 37 * size - offsetY))
      path.addLine(to: CGPoint(x: 23 * size - offsetX, y: 35 * size - offsetY))
      path.addLine(to: CGPoint(x: 21 * size - offsetX, y: 29 * size - offsetY))
      path.addLine(to: CGPoint(x: 22 * size - offsetX, y: 28 * size - offsetY))
      path.addLine(to: CGPoint(x: 26 * size - offsetX, y: 26 * size - offsetY))
      path.addLine(to: CGPoint(x: 34 * size - offsetX, y: 24 * size - offsetY))
      path.addLine(to: CGPoint(x: 46 * size - offsetX, y: 23 * size - offsetY))
      path.addLine(to: CGPoint(x: 46 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 55 * size - offsetX, y: 22 * size - offsetY))
      path.addLine(to: CGPoint(x: 55 * size - offsetX, y: 23 * size - offsetY))
      path.addLine(to: CGPoint(x: 74 * size - offsetX, y: 51 * size - offsetY))
      path.addLine(to: CGPoint(x: 75 * size - offsetX, y: 52 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 52 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 49 * size - offsetY))
      path.addLine(to: CGPoint(x: 78 * size - offsetX, y: 49 * size - offsetY))
      path.addLine(to: CGPoint(x: 80 * size - offsetX, y: 48 * size - offsetY))
      path.addLine(to: CGPoint(x: 79 * size - offsetX, y: 47 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 47 * size - offsetY))
      path.addLine(to: CGPoint(x: 76 * size - offsetX, y: 45 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 45 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 44 * size - offsetY))
      path.addLine(to: CGPoint(x: 75 * size - offsetX, y: 44 * size - offsetY))
      path.addLine(to: CGPoint(x: 74 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 38 * size - offsetY))
      path.addLine(to: CGPoint(x: 77 * size - offsetX, y: 39 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 55 * size - offsetY))
      path.addLine(to: CGPoint(x: 97 * size - offsetX, y: 55 * size - offsetY))
      path.addLine(to: CGPoint(x: 97 * size - offsetX, y: 53 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 53 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 50 * size - offsetY))
      path.addLine(to: CGPoint(x: 102 * size - offsetX, y: 48 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 45 * size - offsetY))
      path.addLine(to: CGPoint(x: 98 * size - offsetX, y: 44 * size - offsetY))
      path.addLine(to: CGPoint(x: 95 * size - offsetX, y: 43 * size - offsetY))
      path.addLine(to: CGPoint(x: 91 * size - offsetX, y: 43 * size - offsetY))
      path.addLine(to: CGPoint(x: 91 * size - offsetX, y: 41 * size - offsetY))
      path.addLine(to: CGPoint(x: 81 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 83 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 87 * size - offsetX, y: 18 * size - offsetY))
      path.addLine(to: CGPoint(x: 90 * size - offsetX, y: 18 * size - offsetY))
      path.addLine(to: CGPoint(x: 95 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 97 * size - offsetX, y: 20 * size - offsetY))
      path.addLine(to: CGPoint(x: 97 * size - offsetX, y: 19 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 18 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 16 * size - offsetY))
      path.addLine(to: CGPoint(x: 99 * size - offsetX, y: 16 * size - offsetY))
      path.addLine(to: CGPoint(x: 101 * size - offsetX, y: 15 * size - offsetY))
      path.addLine(to: CGPoint(x: 102 * size - offsetX, y: 14 * size - offsetY))
      path.addLine(to: CGPoint(x: 101 * size - offsetX, y: 13 * size - offsetY))
      path.addLine(to: CGPoint(x: 99 * size - offsetX, y: 12 * size - offsetY))
      path.addLine(to: CGPoint(x: 100 * size - offsetX, y: 11 * size - offsetY))
      path.addLine(to: CGPoint(x: 102 * size - offsetX, y: 10 * size - offsetY))
      path.addLine(to: CGPoint(x: 103 * size - offsetX, y: 9 * size - offsetY))
      path.addLine(to: CGPoint(x: 102 * size - offsetX, y: 8 * size - offsetY))
      path.addLine(to: CGPoint(x: 99 * size - offsetX, y: 7 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 7 * size - offsetY))
      path.addLine(to: CGPoint(x: 96 * size - offsetX, y: 5 * size - offsetY))
      path.addLine(to: CGPoint(x: 98 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 98 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 94 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 86 * size - offsetX, y: 4 * size - offsetY))
      path.addLine(to: CGPoint(x: 85 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 83 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 80 * size - offsetX, y: 1 * size - offsetY))
      path.addLine(to: CGPoint(x: 75 * size - offsetX, y: 0 * size - offsetY))
      path.addLine(to: CGPoint(x: 64 * size - offsetX, y: 0 * size - offsetY))
      path.addLine(to: CGPoint(x: 59 * size - offsetX, y: 1 * size - offsetY))
      path.addLine(to: CGPoint(x: 55 * size - offsetX, y: 2 * size - offsetY))
      path.addLine(to: CGPoint(x: 52 * size - offsetX, y: 3 * size - offsetY))
      path.addLine(to: CGPoint(x: 50 * size - offsetX, y: 4 * size - offsetY))
      path.addLine(to: CGPoint(x: 43 * size - offsetX, y: 9 * size - offsetY))
      path.addLine(to: CGPoint(x: 22 * size - offsetX, y: 16 * size - offsetY))
      path.addLine(to: CGPoint(x: 13 * size - offsetX, y: 18 * size - offsetY))
      path.addLine(to: CGPoint(x: 3 * size - offsetX, y: 19 * size - offsetY))
      path.addLine(to: CGPoint(x: 1 * size - offsetX, y: 20 * size - offsetY))
    }
    
    path.closeSubpath()
    return path
  }
}
