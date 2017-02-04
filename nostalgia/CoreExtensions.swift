//
//  CoreExtensions.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-03.
//  Copyright © 2016 George Lim. All rights reserved.
//

import SpriteKit

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ^^: ExponentiationPrecedence
public func ^^ (radix: Int, power: Int) -> Int {
  return Int(pow(Double(radix), Double(power)))
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
  static func moveTo(x: CGFloat, withDuration duration: TimeInterval, remove willRemove: Bool = false) -> SKAction {
    let moveAction = SKAction.moveTo(x: x, duration: duration)

    if willRemove {
      let removeAction = SKAction.removeFromParent()
      return SKAction.sequence([moveAction, removeAction])
    } else {
      return moveAction
    }
  }

  static func fade(in fadeIn: Bool, withDuration duration: TimeInterval, waitFirst: TimeInterval = 0, waitLast: TimeInterval = 0) -> SKAction {
    let waitFirstAction = SKAction.wait(forDuration: waitFirst)
    let fadeAction: SKAction
    let waitLastAction = SKAction.wait(forDuration: waitLast)

    switch fadeIn {
    case true:
      fadeAction = .fadeIn(withDuration: duration)
    case false:
      fadeAction = .fadeOut(withDuration: duration)
    }

    return SKAction.sequence([waitFirstAction, fadeAction, waitLastAction])
  }

  static func spawnInfinite(delay: TimeInterval, spawn: @escaping () -> Void) -> SKAction {
    let spawnAction = SKAction.run(spawn)
    let waitAction = SKAction.wait(forDuration: delay)
    let actionSequence = SKAction.sequence([spawnAction, waitAction])
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
