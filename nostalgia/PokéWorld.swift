//
//  PokéWorld.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-04.
//  Copyright © 2016 George Lim. All rights reserved.
//

import UIKit

// MARK: - PokéColors
struct PokéColors {
  static let darkText = UIColor(hex: "#404040")
  static let lightText = UIColor(hex: "#F8F8F8")
  static let greenHealth = UIColor(hex: "#58D080")
  static let greenHealthLight = UIColor(hex: "#70F8A8")
  static let yellowHealth = UIColor(hex: "#C8A808")
  static let yellowHealthLight = UIColor(hex: "#F8E038")
  static let redHealth = UIColor(hex: "#A84048")
  static let redHealthLight = UIColor(hex: "#F85838")
  static let experience = UIColor(hex: "#40C8F8")
}

// MARK: - PokéWorld Error Handling
enum PokéWorldError: Error {
  case playerNotInValidMap, requestedAssetNotFound
}

// MARK: - Global Map
enum Location {
  case testMap, ascendLobby, ascendInGame
}

// MARK: - Pokémon Properties
struct Pokémon {

  let model: String
  let type: [Pokétype]
  let isShiny: Bool

  private let baseHP: Int
  private let xpGroup: PokéXPGroup
  private let hpIV: Int

  private(set) var nickname: String
  private(set) var level: Int
  private(set) var fainted: Bool
  private(set) var hpEV: Int
  private(set) var hp: Int
  private(set) var xp: Int
  private(set) var maxHP: Int!
  private(set) var levelUpXP: Int!

  enum Pokétype {
    case normal, fighting, flying, poison, ground, rock, bug, ghost, steel, fire, water, grass, electric, psychic, ice, dragon, dark
  }

  enum PokéXPGroup {
    case erratic, fast, mediumFast, mediumSlow, slow, fluctuating
  }

  init(model: String, nickname: String, isShiny: Bool, level: Int, fainted: Bool, hpIV: Int, hpEV: Int, hp: Int, xp: Int) {
    self.model = model
    //parse data from model
    type = [.dragon, .psychic]
    baseHP = 80
    xpGroup = .slow

    switch nickname {
    case "":
      self.nickname = model.uppercased()
    default:
      self.nickname = nickname
    }

    self.isShiny = isShiny
    self.level = level
    self.fainted = fainted
    self.hpIV = hpIV
    self.hpEV = hpEV
    self.hp = hp
    self.xp = xp
    maxHP = updateMaxHP()
    levelUpXP = updateLevelUpXP()
  }

  private mutating func updateMaxHP() -> Int {
    return (2 * baseHP + hpIV + hpEV / 4) * level / 100 + level + 10
  }

  private mutating func updateLevelUpXP() -> Int {
    switch xpGroup {
    case .erratic:
      switch level {
      case 1 ..< 50:
        return (level ^ 3) * (100 - level) / 50
      case 50 ..< 68:
        return (level ^ 3) * (150 - level) / 100
      case 68 ..< 98:
        return (level ^ 3) * (1911 - 10 * level) / 1500
      case 98 ... 100:
        return (level ^ 3) * (160 - level) / 100
      default:
        return Int.max
      }
    case .fast:
      return 4 * (level ^ 3) / 5
    case .mediumFast:
      return (level ^ 3)
    case .mediumSlow:
      return (level ^ 3) * 6 / 5 - (level ^ 2) * 15 + level * 100 - 140
    case .slow:
      return 5 * (level ^ 3) / 4
    case .fluctuating:
      switch level {
      case 1 ..< 15:
        return (level ^ 3) * (level + 73) / 150
      case 15 ..< 36:
        return (level ^ 3) * (level + 14) / 50
      case 36 ... 100:
        return (level ^ 3) * (level + 64) / 100
      default:
        return Int.max
      }
    }
  }

  private mutating func levelUp() -> Bool {
    guard 1 ..< 100 ~= level else {
      return false
    }

    level += 1
    return true
  }

  mutating func changeName(to name: String) -> Bool {
    guard name.range(of: "^(?=.*[A-Za-z])[\\s\\S]{1,10}$", options: .regularExpression) != nil else {
      return false
    }

    nickname = name
    return true
  }

  mutating func takeDamage(_ amount: Int) -> Void {
    guard hp - amount >= 0 else {
      hp = 0
      fainted = true
      return
    }

    hp -= amount
  }

  mutating func fullHeal() -> Void {
    hp = maxHP
  }

  mutating func heal(_ amount: Int) -> Void {
    switch hp + amount <= maxHP {
    case true:
      hp += amount
    case false:
      fullHeal()
    }

    guard fainted else {
      return
    }

    fainted = false
  }

  mutating func addXPLevelUp(_ amount: Int) -> Bool {
    guard level < 100 else {
      return false
    }

    xp += abs(amount)
    guard xp >= levelUpXP else {
      return false
    }

    while (xp >= levelUpXP) {
      xp -= levelUpXP

      if levelUp() {
        levelUpXP = updateLevelUpXP()
      }
    }

    return true
  }
}

// Configuration Options for Ascend
struct AscendConfig {
  var activePokémon: Pokémon
}

// MARK: - Trainer
struct Trainer {
  static var name = "George"
  static var currentLocation = Location.ascendLobby
  static var currentAction = "N/A"
  static var team: [Pokémon] = [Pokémon(model: "latios", nickname: "", isShiny: true, level: 99, fainted: false, hpIV: 31, hpEV: 252, hp: 300, xp: 100)]

  static var ascend: AscendConfig = AscendConfig(activePokémon: team[0])
}
