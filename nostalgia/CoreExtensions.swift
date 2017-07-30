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
  
  // Returns a random number CGFloat.
  static func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  // Returns a random CGFloat value between in [min, max).
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
  
  static var darkText: UIColor {
    return UIColor(hex: "#404040")
  }
  
  static var lightText: UIColor {
    return UIColor(hex: "#F8F8F8")
  }
  
  static var greenHealth: UIColor {
    return UIColor(hex: "#58D080")
  }
  
  static var greenHealthLight: UIColor {
    return UIColor(hex: "#70F8A8")
  }
  
  static var yellowHealth: UIColor {
    return UIColor(hex: "#C8A808")
  }
  
  static var yellowHealthLight: UIColor {
    return UIColor(hex: "#F8E038")
  }
  
  static var redHealth: UIColor {
    return UIColor(hex: "#A84048")
  }
  
  static var redHealthLight: UIColor {
    return UIColor(hex: "#F85838")
  }
  
  static var exp: UIColor {
    return UIColor(hex: "#40C8F8")
  }
}

extension SKAction {
  
  // Custom SKAction which includes the option to remove the node directly after moving to a specific x position.
  static func moveTo(x: CGFloat, withDuration duration: TimeInterval, remove: Bool = false) -> SKAction {
    let moveAction = SKAction.moveTo(x: x, duration: duration)
    
    if (remove) {
      let removeAction = SKAction.removeFromParent()
      return SKAction.sequence([moveAction, removeAction])
    }
    return moveAction
  }
  
  // Custom fade function which includes option to switch fade effects and add delays before and after fading.
  static func fade(in fadeIn: Bool, withDuration duration: TimeInterval, waitFirst: TimeInterval = 0, waitLast: TimeInterval = 0) -> SKAction {
    let waitFirstAction = SKAction.wait(forDuration: waitFirst)
    let fadeAction: SKAction
    let waitLastAction = SKAction.wait(forDuration: waitLast)
    
    if (fadeIn) {
      fadeAction = .fadeIn(withDuration: duration)
    } else {
      fadeAction = .fadeOut(withDuration: duration)
    }
    
    return SKAction.sequence([waitFirstAction, fadeAction, waitLastAction])
  }
  
  // Custom action which enables an escaping function to be called indefinitely after a specified delay.
  static func spawnInfinite(delay: TimeInterval, spawn: @escaping () -> Void) -> SKAction {
    let spawnAction = SKAction.run(spawn)
    let waitAction = SKAction.wait(forDuration: delay)
    let actionSequence = SKAction.sequence([spawnAction, waitAction])
    return SKAction.repeatForever(actionSequence)
  }
}

extension SKNode {
  // Runs an action and provides a completion handler.
  func runAction(action: SKAction, withKey: String, completion: @escaping () -> Void) {
    let completionAction = SKAction.run(completion)
    let actionSequence = SKAction.sequence([action, completionAction])
    run(actionSequence, withKey: withKey)
  }
}
