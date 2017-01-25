//
//  CoreExtensions.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-03.
//  Copyright © 2016 George Lim. All rights reserved.
//

import SpriteKit

precedencegroup ExponentiativePrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}


// Fix Power errors
infix operator ^: ExponentiativePrecedence
func ^ (radix: Double, power: Double) -> Int {
  return Int(pow(radix, power))
}

extension CGFloat {

  static func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return min + CGFloat.random() * (max - min)
  }
}

extension UIColor {

  convenience init(hex: String, alpha: CGFloat = 1) {
    var hexValue: UInt32 = 0
    Scanner(string: hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))).scanHexInt32(&hexValue)
    self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255, blue: CGFloat(hexValue & 0x0000FF) / 255, alpha: alpha)
  }
}

extension SKAction {

  static func moveToXAndRemove(_ x: CGFloat, duration: TimeInterval) -> SKAction {
    let moveToX = SKAction.moveTo(x: x, duration: duration)
    let remove = SKAction.removeFromParent()
    return (SKAction.sequence([moveToX, remove]))
  }

  static func spawnInfinite(delay: TimeInterval, spawn: @escaping () -> Void) -> SKAction {
    let delayAction = SKAction.wait(forDuration: delay)
    let spawnAction = SKAction.run(spawn)
    let actionSequence = SKAction.sequence([spawnAction, delayAction])
    return SKAction.repeatForever(actionSequence)
  }
}

extension SKNode {

  func runAction(action: SKAction, withKey: String, completion: @escaping () -> Void) -> Void {
    let completionAction = SKAction.run(completion)
    let actionSequence = SKAction.sequence([action, completionAction])
    run(actionSequence, withKey: withKey)
  }
}
