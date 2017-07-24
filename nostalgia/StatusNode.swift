//
//  StatusNode.swift
//  nostalgia
//
//  Created by George Lim on 2017-05-08.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

// position and name
class StatusNode: SKSpriteNode {
  private var pokemon: Pokemon!
  private var hpBarWidth: CGFloat!
  private var expBarWidth: CGFloat!
  
  override init(texture: SKTexture!, color: SKColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  convenience init(in scene: GameScene) {
    self.init(imageNamed: "pokemon_status")
    
    pokemon = scene.pokemon

    name = "statusNode"
    setScale(scene.landscape.spriteScale)
    zPosition = 200
    
    let hpBar = SKSpriteNode()
    hpBar.name = "hpBar"
    hpBar.size = CGSize(width: 47.75, height: 0.9875)
    hpBar.anchorPoint = CGPoint.zero
    hpBar.position = CGPoint(x: -8.375, y: -4)
    hpBar.zPosition = 1
    
    hpBarWidth = hpBar.size.width
    
    let hpBarLight = SKSpriteNode()
    hpBarLight.name = "hpBarLight"
    hpBarLight.size = hpBar.size
    hpBarLight.anchorPoint = hpBar.anchorPoint
    hpBarLight.position = CGPoint(x: hpBar.position.x, y: hpBar.position.y - hpBar.size.height)
    hpBarLight.zPosition = 1
    
    let expBar = SKSpriteNode()
    expBar.color = UIColor.exp
    expBar.name = "expBar"
    expBar.size = CGSize(width: 64, height: 1.975)
    expBar.anchorPoint = CGPoint.zero
    expBar.position = CGPoint(x: -24.5, y: -20.875)
    expBar.zPosition = 1
    
    expBarWidth = expBar.size.width
    
    let nameLabel = SKLabelNode(fontNamed: "Pokemon Emerald")
    nameLabel.fontColor = UIColor.darkText
    nameLabel.fontSize = 10
    nameLabel.name = "nameLabel"
    nameLabel.horizontalAlignmentMode = .left
    nameLabel.position = CGPoint(x: -41.5, y: 1)
    nameLabel.zPosition = 1
    
    let levelLabel = SKLabelNode(fontNamed: "Pokemon Emerald")
    levelLabel.fontColor = UIColor.darkText
    levelLabel.fontSize = 10
    levelLabel.name = "levelLabel"
    levelLabel.horizontalAlignmentMode = .right
    levelLabel.position = CGPoint(x: 39, y: 1)
    levelLabel.zPosition = 1
    
    let hpLabel = SKLabelNode(fontNamed: "Pokemon Emerald")
    hpLabel.fontColor = UIColor.darkText
    hpLabel.fontSize = 10
    hpLabel.name = "hpLabel"
    hpLabel.horizontalAlignmentMode = .right
    hpLabel.position = CGPoint(x: 39, y: -16.5)
    hpLabel.zPosition = 1
    
    addChild(hpBar)
    addChild(hpBarLight)
    addChild(expBar)
    addChild(nameLabel)
    addChild(levelLabel)
    addChild(hpLabel)
    
    updateName()
    updateHP()
    updateEXP()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func updateName() {
    let nameLabel = childNode(withName: "nameLabel") as! SKLabelNode
    if let nickname = pokemon.nickname {
      nameLabel.text = nickname
    } else {
      nameLabel.text = pokemon.model.uppercased()
    }
  }
  
  func updateHP() {
    let hpFraction = CGFloat(pokemon.hp / pokemon.maxHP)

    let hpBar = childNode(withName: "hpBar") as! SKSpriteNode
    hpBar.size.width = hpBarWidth * hpFraction
    
    let hpBarLight = childNode(withName: "hpBarLight") as! SKSpriteNode
    hpBarLight.size.width = hpBar.size.width
    
    let hpLabel = childNode(withName: "hpLabel") as! SKLabelNode
    hpLabel.text = "\(pokemon.hp)/\(pokemon.maxHP)"
    
    switch hpFraction {
    case 0 ... 0.2:
      hpBar.color = UIColor.redHealth
      hpBarLight.color = UIColor.redHealthLight
    case 0.2 ... 0.5:
      hpBar.color = UIColor.yellowHealth
      hpBarLight.color = UIColor.yellowHealthLight
    default:
      hpBar.color = UIColor.greenHealth
      hpBarLight.color = UIColor.greenHealthLight
    }
  }
  
  func updateEXP() {
    let expBar = childNode(withName: "expBar") as! SKSpriteNode
    expBar.size.width = expBarWidth * CGFloat(pokemon.exp / pokemon.maxEXP)
    
    let levelLabel = childNode(withName: "levelLabel") as! SKLabelNode
    levelLabel.text = "Lv\(pokemon.level)"
  }
}
