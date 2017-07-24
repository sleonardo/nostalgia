//
//  Pokemon.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-04.
//  Copyright © 2016 George Lim. All rights reserved.
//

import UIKit

class Pokemon {
  let model: String
  let shiny: Bool
  
  var nickname: String? {
    didSet {
      if (nickname != nil && nickname!.range(of: "^(?=.*[A-Za-z])[\\s\\S]{1,10}$", options: .regularExpression) == nil) {
        nickname = oldValue
      }
    }
  }
  
  var fainted: Bool {
    return hp == 0
  }

  var hp: Int {
    didSet {
      if (hp < 0) {
        hp = 0
      } else if (hp > maxHP) {
        hp = maxHP
      }
    }
  }
  
  var maxHP: Int {
    return 254 * level / 100 + level + 10
  }
  
  var maxLevel: Bool {
    return level == 100
  }
  
  var level: Int {
    didSet {
      if (level <= oldValue || level > 100) {
        level = oldValue
      } else {
        if (level == 100) {
          exp = 0
        } else {
          exp -= maxEXP
        }
      }
    }
  }
  
  var exp: Int {
    didSet {
      if (exp < oldValue) {
        exp = oldValue
      }
      
      while (!maxLevel && exp >= maxEXP) {
        level += 1
      }
    }
  }
  
  var maxEXP: Int {
    return 5 * level ^^ 3 / 4
  }
  
  init(model: String, shiny: Bool, nickname: String?, hp: Int, level: Int, exp: Int) {
    self.model = model
    self.shiny = shiny
    self.nickname = nickname
    self.hp = hp
    self.level = level
    self.exp = exp
  }
  
  func damage(_ amount: Int) {
    hp -= abs(amount)
  }
  
  func fullHeal() {
    hp = maxHP
  }
  
  func heal(_ amount: Int) {
    hp += abs(amount)
  }
  
  func increaseXP(_ amount: Int) {
    exp += abs(amount)
  }
}
