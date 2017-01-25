//
//  AscendGame.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-01.
//  Copyright © 2016 George Lim. All rights reserved.
//

import SpriteKit

// MARK: - Physics Category
private enum PhysicsCategory: UInt32 {
  case player = 1
  case groundBarrier = 2
  case scoreZone = 4
  case boulder = 8
  case scoreUI = 16
}

// MARK: - Landscape
private struct Landscape {

  let mapScale: CGFloat
  let spriteScale: CGFloat
  let blockWidth: CGFloat
  let blocksForAnimation: Int
  let animatingNodes: [String]
  let animatingNodeSpeeds: [CGFloat]
  let groundHeight: CGFloat
  let skyCenter: CGFloat

  init(sceneWidth: CGFloat, sceneHeight: CGFloat) {
    let blockWidth: CGFloat = 256
    let blockHeight: CGFloat = 512

    mapScale = sceneWidth / blockWidth
    spriteScale = sceneHeight / blockHeight

    self.blockWidth = blockWidth * spriteScale
    blocksForAnimation = Int(ceil(sceneWidth * 2 / blockWidth))

    animatingNodes = ["background", "trees-d", "trees-c", "trees-b", "trees-a1", "ground"]
    animatingNodeSpeeds = [0.1 * spriteScale, 0.25 * spriteScale, 0.5 * spriteScale, 1 * spriteScale, 2 * spriteScale, 12 * spriteScale]

    groundHeight = 110 * spriteScale
    skyCenter = (sceneHeight + groundHeight) / 2
  }
}

// MARK: - Ring Spawner
private struct Spawner {

  private(set) var summonRings: SKAction

  init() {
    summonRings = SKAction()
  }

  mutating func updateRing(_ scene: SKScene, mapScale: CGFloat, spriteScale: CGFloat, skyCenter: CGFloat, boulder: CGPath) -> Void {
    let ringWidth: CGFloat = 120
    let ringHeight: CGFloat = 192
    let boulderHeight: CGFloat = 30
    let boulderHeightOffset: CGFloat = 3

    let finalX = scene.size.width + ringWidth * spriteScale / 2
    let travelTime = TimeInterval(finalX * (0.0075 - CGFloat(Trainer.ascend.activePokémon.level) * 0.000025) / mapScale)
    let spawnDelay = travelTime * (0.5 + TimeInterval(Trainer.ascend.activePokémon.level) / 600)
    let spawnRadius = scene.size.height - skyCenter - ringHeight * spriteScale / 2

    summonRings = .spawnInfinite(delay: spawnDelay, spawn: {
      () -> Void in
      let ring = SKSpriteNode(imageNamed: "boulder-ring")
      ring.setScale(spriteScale)

      let spawnOffset = CGFloat.random(min: -spawnRadius, max: spawnRadius)
      ring.position = CGPoint(x: -ringWidth * spriteScale / 2, y: skyCenter + spawnOffset)
      ring.zPosition = 99

      let ringOverlay = SKSpriteNode(imageNamed: "boulder-ring-overlay")
      ringOverlay.position = CGPoint(x: -(ringWidth - ringOverlay.size.width) / 2, y: -1)
      ringOverlay.zPosition = 2

      let upperBarrier = SKSpriteNode()
      upperBarrier.position.y = (ringHeight - boulderHeight - boulderHeightOffset) / 2

      upperBarrier.physicsBody = SKPhysicsBody(polygonFrom: boulder)
      upperBarrier.physicsBody?.affectedByGravity = false
      upperBarrier.physicsBody?.isDynamic = false
      upperBarrier.physicsBody?.categoryBitMask = PhysicsCategory.boulder.rawValue

      let scoreZone = SKSpriteNode()
      scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: ringHeight - boulderHeight * 2))
      scoreZone.physicsBody?.affectedByGravity = false
      scoreZone.physicsBody?.isDynamic = false
      scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone.rawValue

      let lowerBarrier = SKSpriteNode()
      lowerBarrier.position.y = -(ringHeight - boulderHeight - boulderHeightOffset) / 2

      lowerBarrier.physicsBody = SKPhysicsBody(polygonFrom: boulder)
      lowerBarrier.physicsBody?.affectedByGravity = false
      lowerBarrier.physicsBody?.isDynamic = false
      lowerBarrier.physicsBody?.categoryBitMask = PhysicsCategory.boulder.rawValue

      ring.addChild(ringOverlay)
      ring.addChild(upperBarrier)
      ring.addChild(scoreZone)
      ring.addChild(lowerBarrier)

      scene.addChild(ring)

      ring.run(.moveToXAndRemove(finalX, duration: travelTime))
    })
  }
}

// MARK: - Game UI
private struct GameUI {

  private let scoreUI: ScoreUI
  private let statusUI: StatusUI

  private(set) var currentScore: Int
  private(set) var successfulRecoveries: Int

  private struct ScoreUI {

    private let node: SKSpriteNode

    init(node: SKSpriteNode) {
      self.node = node
      updateScore()
    }

    func updateScore(_ newScore: Int = 0) -> Void {
      let scoreText = node.childNode(withName: "scoreText") as! SKLabelNode
      scoreText.text = "SCORE: \(newScore)"
    }
  }

  private struct StatusUI {

    fileprivate let node: SKSpriteNode
    private let hpBarWidth: CGFloat
    private let xpBarWidth: CGFloat

    init(node: SKSpriteNode) {
      self.node = node
      let hpBar = node.childNode(withName: "hpBar") as! SKSpriteNode
      hpBarWidth = hpBar.size.width

      let xpBar = node.childNode(withName: "xpBar") as! SKSpriteNode
      xpBarWidth = xpBar.size.width
    }

    func fade(_ fadeIn: Bool, startDelay: TimeInterval = 0, endDelay: TimeInterval = 0) -> SKAction {
      let delayBeforeAction = SKAction.wait(forDuration: startDelay)
      let delayAfterAction = SKAction.wait(forDuration: endDelay)
      let fadeAction: SKAction
      switch fadeIn {
      case true:
        fadeAction = .fadeIn(withDuration: 0.25)
      case false:
        fadeAction = .fadeOut(withDuration: 0.25)
      }

      return SKAction.sequence([delayBeforeAction, fadeAction, delayAfterAction])
    }

    func updateName() -> Void {
      let nameText = node.childNode(withName: "nameText") as! SKLabelNode
      nameText.text = Trainer.ascend.activePokémon.nickname
    }

    func updateHP(_ originalHP: Int, newRatio: CGFloat, color: UIColor, colorLight: UIColor) -> Void {
      let hpBar = node.childNode(withName: "hpBar") as! SKSpriteNode
      let hpBarLight = node.childNode(withName: "hpBarLight") as! SKSpriteNode
      let hpText = node.childNode(withName: "hpText") as! SKLabelNode

      guard originalHP != Trainer.ascend.activePokémon.hp else {
        hpBar.color = color
        hpBar.size.width = hpBarWidth * newRatio

        hpBarLight.color = colorLight
        hpBarLight.size.width = hpBar.size.width

        hpText.text = "\(Trainer.ascend.activePokémon.hp)/\(Trainer.ascend.activePokémon.maxHP)"
        return
      }

      var currentHPBarWidth = hpBar.size.width
      var deltaWidth = currentHPBarWidth * newRatio - currentHPBarWidth
      var increment: Int
      switch deltaWidth > 0 {
      case true:
        increment = 1
      case false:
        increment = -1
        deltaWidth *= -1
      }

      let updateHPBarAction = SKAction.run({
        () -> Void in
        let hpRatio = currentHPBarWidth / self.hpBarWidth
        let (hpColor, hpColorLight) = GameUI.getHPColor(hpRatio)

        hpBar.color = hpColor
        hpBar.size.width = currentHPBarWidth

        hpBarLight.color = hpColorLight
        hpBarLight.size.width = hpBar.size.width

        currentHPBarWidth += CGFloat(increment)
      })

      var delayAction = SKAction.wait(forDuration: 0.25)
      var actionSequence = SKAction.sequence([updateHPBarAction, delayAction])
      let animateHPBar = SKAction.repeat(actionSequence, count: Int(deltaWidth))

      var currentHP = originalHP
      var deltaHP = Trainer.ascend.activePokémon.hp - currentHP
      switch deltaHP > 0 {
      case true:
        increment = 1
      case false:
        increment = -1
        deltaHP *= -1
      }

      let updateHPTextAction = SKAction.run({
        () -> Void in
        hpText.text = "\(currentHP)/\(Trainer.ascend.activePokémon.maxHP)"
        currentHP += increment
      })

      delayAction = SKAction.wait(forDuration: 0.33 * Double(deltaWidth) / Double(deltaHP))
      actionSequence = SKAction.sequence([updateHPTextAction, delayAction])
      let animateHPText = SKAction.repeat(actionSequence, count: deltaHP)

      let animateHP = SKAction.group([animateHPBar, animateHPText])
      switch node.action(forKey: "animateHP") == nil {
      case true:
        actionSequence = SKAction.sequence([fade(true, endDelay: 0.25), animateHP, fade(false, startDelay: 1.25)])
      case false:
        actionSequence = SKAction.sequence([animateHP, fade(false, startDelay: 1.25)])
      }

      node.run(actionSequence, withKey: "animateHP")
    }

    func updateXP(_ newRatio: CGFloat, willLevelUp: Bool) -> Void {
      let xpBar = node.childNode(withName: "xpBar") as! SKSpriteNode
      xpBar.color = PokéColors.experience
      xpBar.size.width = xpBarWidth * newRatio

      guard willLevelUp else {
        return
      }

      let levelText = node.childNode(withName: "levelText") as! SKLabelNode
      levelText.text = "Lv\(Trainer.ascend.activePokémon.level)"
      //animate Level up
    }
  }

  init(scoreUI: SKSpriteNode, statusUI: SKSpriteNode) {
    self.scoreUI = ScoreUI(node: scoreUI)
    self.statusUI = StatusUI(node: statusUI)
    currentScore = 0
    successfulRecoveries = 0
    updateHP()
    updateXP()
  }

  func showStatusUI(_ fadeIn: Bool, startDelay: TimeInterval = 0, endDelay: TimeInterval = 0) -> Void {
    let fadeAction = statusUI.fade(fadeIn, startDelay: startDelay, endDelay: endDelay)
    statusUI.node.run(fadeAction)
  }

  mutating func newRound() -> Void {
    currentScore = 0
    successfulRecoveries = 0
  }

  mutating func increaseScore() -> Void {
    currentScore += 1
    scoreUI.updateScore(currentScore)
  }

  mutating func playerRecovered() -> Void {
    successfulRecoveries += 1
  }

  private static func getHPColor(_ hpRatio: CGFloat) -> (hpColor: UIColor, hpColorLight: UIColor) {
    switch hpRatio {
    case 0 ... 0.2:
      return(PokéColors.redHealth, PokéColors.redHealthLight)
    case 0.2 ... 0.5:
      return (PokéColors.yellowHealth, PokéColors.yellowHealthLight)
    default:
      return (PokéColors.greenHealth, PokéColors.greenHealthLight)
    }
  }

  private func updateHP(_ originalHP: Int = Trainer.ascend.activePokémon.hp) -> Void {
    let hpRatio = CGFloat(Trainer.ascend.activePokémon.hp) / CGFloat(Trainer.ascend.activePokémon.maxHP)
    let (hpColor, hpColorLight) = GameUI.getHPColor(hpRatio)
    statusUI.updateHP(originalHP, newRatio: hpRatio, color: hpColor, colorLight: hpColorLight)
  }

  func takeDamage(_ amount: Int) -> Void {
    let originalHP = Trainer.ascend.activePokémon.hp
    Trainer.ascend.activePokémon.takeDamage(abs(amount))
    updateHP(originalHP)

    guard Trainer.ascend.activePokémon.hp == 0 else {
      return
    }

    //Animate what happens when Pokémon Faints
  }

  func updateXP(_ amount: Int = 0) -> Void {
    var levelUp = false
    if amount > 0 {
      levelUp = Trainer.ascend.activePokémon.addXPLevelUp(amount)
    }

    let xpRatio = CGFloat(Trainer.ascend.activePokémon.xp) / CGFloat(Trainer.ascend.activePokémon.levelUpXP)
    statusUI.updateXP(xpRatio, willLevelUp: levelUp)
  }
}

class AscendGame: SKScene {

  // MARK: - Globals
  private var landscape: Landscape!
  private var spawner: Spawner!
  fileprivate var gameUI: GameUI!
  fileprivate var statusUI: SKSpriteNode!
  // MARK: - Pokémon-related Globals
  private var player: SKSpriteNode!
  // MARK: - In-game Globals
  private var flyHeight: CGFloat!
  private var ascending = false
  fileprivate var recovering = false // NEED TO USE THIS

  override func didMove(to view: SKView) -> Void {
    physicsWorld.contactDelegate = self
    backgroundColor = UIColor(hex: "#C6E7FF")
    landscape = Landscape(sceneWidth: size.width, sceneHeight: size.height)
    spawner = Spawner()

    do {
      paintLandscape()
      try updatePokémon()
      loadUI()
    } catch {
      print("The requested asset could not be found.")
    }
  }

  private func paintLandscape() -> Void {
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

        if 1 ... 4 ~= i {
          node.position.y = treeOffset
        }

        addChild(node)
      }
    }

    let groundBarrier = SKSpriteNode()
    groundBarrier.position = CGPoint(x: size.width / 2, y: landscape.groundHeight)

    groundBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
    groundBarrier.physicsBody?.affectedByGravity = false
    groundBarrier.physicsBody?.isDynamic = false
    groundBarrier.physicsBody?.categoryBitMask = PhysicsCategory.groundBarrier.rawValue

    addChild(groundBarrier)
  }

  private func getSpriteBody(_ model: String, size: CGFloat = 1) -> CGPath? {
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

    case "latios":
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

    case "boulder":
      offsetX = 27 / 2
      offsetY = 30 / 2

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

    default:
      return nil
    }

    path.closeSubpath()
    return path
  }

  private func updatePokémon() throws -> Void {
    let pokéSize = (0.9 + CGFloat(Trainer.ascend.activePokémon.level) * 0.002) * landscape.spriteScale
    var pokéSprite = Trainer.ascend.activePokémon.model
    if Trainer.ascend.activePokémon.isShiny {
      pokéSprite += "-shiny"
    }

    player = SKSpriteNode(imageNamed: pokéSprite)
    player.setScale(pokéSize)
    player.position = CGPoint(x: size.width / 2, y: landscape.skyCenter + player.size.height)
    player.zPosition = 100

    guard let pokéBody = getSpriteBody(Trainer.ascend.activePokémon.model, size: pokéSize), let boulder = getSpriteBody("boulder") else {
      throw PokéWorldError.requestedAssetNotFound
    }

    player.physicsBody = SKPhysicsBody(polygonFrom: pokéBody)
    player.physicsBody?.affectedByGravity = false
    player.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
    player.physicsBody?.collisionBitMask = PhysicsCategory.groundBarrier.rawValue | PhysicsCategory.boulder.rawValue
    player.physicsBody?.contactTestBitMask = PhysicsCategory.groundBarrier.rawValue | PhysicsCategory.boulder.rawValue | PhysicsCategory.scoreZone.rawValue

    physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * pokéSize)
    flyHeight = player.size.height * 2
    spawner.updateRing(self, mapScale: landscape.mapScale, spriteScale: pokéSize, skyCenter: landscape.skyCenter, boulder: boulder)

    addChild(player)
  }

  private func loadUI() -> Void {
    let scoreUI = SKSpriteNode(imageNamed: "signPost")
    scoreUI.setScale(landscape.spriteScale)
    scoreUI.position = CGPoint(x: scoreUI.size.width / 2 + 10 * landscape.spriteScale, y: size.height - scoreUI.size.height / 2 - 10 * landscape.spriteScale)
    scoreUI.zPosition = 200

    let scoreText = SKLabelNode(fontNamed: "Pokemon Emerald")
    scoreText.fontColor = PokéColors.lightText
    scoreText.fontSize = 14
    scoreText.name = "scoreText"
    scoreText.verticalAlignmentMode = .center
    scoreText.zPosition = 1

    scoreUI.addChild(scoreText)

    statusUI = SKSpriteNode(imageNamed: "pokeStatusUI")
    statusUI.setScale(landscape.spriteScale)
    statusUI.zPosition = 200

    let hpBar = SKSpriteNode()
    hpBar.name = "hpBar"
    hpBar.size = CGSize(width: 47.75, height: 0.9875)
    hpBar.anchorPoint = CGPoint.zero
    hpBar.position = CGPoint(x: -8.375, y: -4)
    hpBar.zPosition = 1

    let hpBarLight = SKSpriteNode()
    hpBarLight.name = "hpBarLight"
    hpBarLight.size = hpBar.size
    hpBarLight.anchorPoint = hpBar.anchorPoint
    hpBarLight.position = CGPoint(x: hpBar.position.x, y: hpBar.position.y - hpBar.size.height)
    hpBarLight.zPosition = 1

    let xpBar = SKSpriteNode()
    xpBar.name = "xpBar"
    xpBar.size = CGSize(width: 64, height: 1.975)
    xpBar.anchorPoint = CGPoint.zero
    xpBar.position = CGPoint(x: -24.5, y: -20.875)
    xpBar.zPosition = 1

    let nameText = SKLabelNode(fontNamed: "Pokemon Emerald")
    nameText.fontColor = PokéColors.darkText
    nameText.fontSize = 10
    nameText.name = "nameText"
    nameText.text = Trainer.ascend.activePokémon.nickname
    nameText.horizontalAlignmentMode = .left
    nameText.position = CGPoint(x: -41.5, y: 1)
    nameText.zPosition = 1

    let levelText = SKLabelNode(fontNamed: "Pokemon Emerald")
    levelText.fontColor = PokéColors.darkText
    levelText.fontSize = 10
    levelText.name = "levelText"
    levelText.text = "Lv\(Trainer.ascend.activePokémon.level)"
    levelText.horizontalAlignmentMode = .right
    levelText.position = CGPoint(x: 39, y: 1)
    levelText.zPosition = 1

    let hpText = SKLabelNode(fontNamed: "Pokemon Emerald")
    hpText.fontColor = PokéColors.darkText
    hpText.fontSize = 10
    hpText.name = "hpText"
    hpText.horizontalAlignmentMode = .right
    hpText.position = CGPoint(x: 39, y: -16.5)
    hpText.zPosition = 1

    statusUI.addChild(hpBar)
    statusUI.addChild(hpBarLight)
    statusUI.addChild(xpBar)
    statusUI.addChild(nameText)
    statusUI.addChild(levelText)
    statusUI.addChild(hpText)

    moveStatusUI()

    gameUI = GameUI(scoreUI: scoreUI, statusUI: statusUI)

    addChild(scoreUI)
    addChild(statusUI)
  }

  private func moveStatusUI() -> Void {
    statusUI.position = CGPoint(x: player.position.x, y: player.position.y - (player.frame.height + statusUI.size.height) / 2 - 5)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) -> Void {
    guard (try? navigateUser()) != nil else {
      print("Character is not in a valid map.")
      return
    }
  }

  private func navigateUser() throws -> Void {
    switch Trainer.currentLocation {
    case .ascendInGame:
      guard !recovering else {
        return
      }

      ascending = true

    case .ascendLobby:
      Trainer.currentLocation = .ascendInGame
      player.physicsBody?.affectedByGravity = true
      run(spawner.summonRings)
      gameUI.showStatusUI(false)
    default:
      throw PokéWorldError.playerNotInValidMap
    }
  }

  override func update(_ currentTime: TimeInterval) -> Void {
    animateLandscape()
    moveStatusUI()

    switch Trainer.currentLocation {
    case .ascendInGame:
      if ascending && !recovering {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: player.physicsBody!.velocity.dy + flyHeight)
      }
    default:
      break
    }
  }

  private func animateLandscape() -> Void {
    let landscapeNodes = landscape.animatingNodes.count
    for i in 0 ..< landscapeNodes {
      enumerateChildNodes(withName: landscape.animatingNodes[i], using: {
        node, error -> Void in
        let sprite = node as! SKSpriteNode
        if sprite.position.x >= self.landscape.blockWidth * CGFloat(self.landscape.blocksForAnimation - 1) {
          sprite.position.x = -self.landscape.blockWidth
        }

        sprite.position.x += self.landscape.animatingNodeSpeeds[i]
      })
    }
  }

  //  private func flightRecovery() -> Void {
  //    recovering = true
  //    let playerCategoryBitMask = contact.bodyA.categoryBitMask
  //    let playerCollisionBitMask = contact.bodyA.collisionBitMask
  //    contact.bodyA.categoryBitMask = 0
  //    contact.bodyA.collisionBitMask = 0
  //    gameUI.takeDamage(Trainer.ascend.activePokémon.maxHP / 24)
  //    gameUI.playerRecovered()
  //
  //    let recoverAction = SKAction.moveTo(CGPoint(x: size.width / 2, y: landscape.skyCenter + player.size.height), duration: 0.5)
  //    player.runAction(recoverAction, completion: {
  //      () -> Void in
  //      self.recovering = false
  //      contact.bodyA.categoryBitMask = playerCategoryBitMask
  //      contact.bodyA.collisionBitMask = playerCollisionBitMask
  //    })
  //  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) -> Void {
    super.touchesEnded(touches, with: event) //Remove?
    if !recovering {
      ascending = false
    }
  }
}

extension AscendGame: SKPhysicsContactDelegate {

  func didBegin(_ contact: SKPhysicsContact) -> Void {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    case PhysicsCategory.player.rawValue | PhysicsCategory.boulder.rawValue:
      let chanceToRecover = Int(CGFloat.random(min: 0, max: 100))
      switch chanceToRecover < 50 - gameUI.successfulRecoveries * 10 {
      case true:
        recovering = true
      case false:
        //player is dead
        break
      }
    case PhysicsCategory.player.rawValue | PhysicsCategory.scoreZone.rawValue:
      contact.bodyB.categoryBitMask = 0
      gameUI.increaseScore()
    default:
      break
    }
  }
  
  func didEnd(_ contact: SKPhysicsContact) -> Void {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    case PhysicsCategory.player.rawValue | PhysicsCategory.boulder.rawValue:
      break
    case PhysicsCategory.player.rawValue | PhysicsCategory.scoreZone.rawValue:
      break
    default:
      break
    }
  }
}
