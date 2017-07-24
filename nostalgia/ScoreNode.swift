//
//  ScoreNode.swift
//  nostalgia
//
//  Created by George Lim on 2017-05-07.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

class ScoreNode: SKSpriteNode {
  var score: Int = 0 {
    didSet {
      if (!(score == 0 || score == oldValue + 1)) {
        score = oldValue
      } else {
        updateScore()
      }
    }
  }
  
  override init(texture: SKTexture!, color: SKColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  convenience init(in scene: GameScene) {
    self.init(imageNamed: "score_board")
    
    name = "scoreNode"
    setScale(scene.landscape.spriteScale)
    position = CGPoint(x: size.width / 2 + 10 * scene.landscape.spriteScale, y: scene.size.height - size.height / 2 - 10 * scene.landscape.spriteScale)
    zPosition = 200
    
    let scoreLabel = SKLabelNode(fontNamed: "Pokemon Emerald")
    scoreLabel.fontColor = UIColor.lightText
    scoreLabel.fontSize = 14
    scoreLabel.name = "scoreLabel"
    scoreLabel.verticalAlignmentMode = .center
    scoreLabel.zPosition = 1
    
    addChild(scoreLabel)
    
    updateScore()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func updateScore() {
    let scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
    scoreLabel.text = "SCORE: \(score)"
  }
  
  func increaseScore() {
    score += 1
  }
  
  func resetScore() {
    score = 0
  }
}
