//
//  GameHub.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-04.
//  Copyright © 2016 George Lim. All rights reserved.
//

import UIKit

// MARK: - GameHub errors
enum GameHubError: Error {
  case playerNotInValidMap, requestedAssetNotFound
}

// MARK: - Game maps
enum GameMap {
  case test, ascendLobby, ascendInGame
}

// MARK: - Pokémon info
class Pokémon {
  private let model: String
  private let type: [Pokétype]
  private let baseHP: Int
  private let xpGroup: PokéXPGroup

  private let shiny: Bool
  private let hpIV: Int

  private var nickname: String
  private var level: Int
  private var fainted: Bool
  private var hpEV: Int
  private var hp: Int
  private var xp: Int
  private var maxHP: Int = -1
  private var levelUpXP: Int = -1

  enum Pokétype {
    case normal, fighting, flying, poison, ground, rock, bug, ghost, steel, fire, water, grass, electric, psychic, ice, dragon, dark
  }

  enum PokéXPGroup {
    case erratic, fast, mediumFast, mediumSlow, slow, fluctuating
  }

  init(model: String, nickname: String, shiny: Bool, level: Int, fainted: Bool, hpIV: Int, hpEV: Int, hp: Int, xp: Int) {
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

    self.shiny = shiny
    self.level = level
    self.fainted = fainted
    self.hpIV = hpIV
    self.hpEV = hpEV
    self.hp = hp
    self.xp = xp
    self.maxHP = setMaxHP()
    self.levelUpXP = setLevelUpXP()
  }

  func getModel() -> String {
    return model
  }

  func getNickname() -> String {
    return nickname
  }

  func setNickname(to name: String) -> Bool {
    guard name.range(of: "^(?=.*[A-Za-z])[\\s\\S]{1,10}$", options: .regularExpression) != nil else {
      return false
    }

    nickname = name
    return true
  }

  func isShiny() -> Bool {
    return shiny
  }

  func getLevel() -> Int {
    return level
  }

  private func levelUp() -> Bool {
    guard 1 ..< 100 ~= level else {
      return false
    }

    level += 1
    return true
  }

  func hasFainted() -> Bool {
    return fainted
  }

  func getHPEV() -> Int {
    return hpEV
  }

  func getHP() -> Int {
    return hp
  }

  func getMaxHP() -> Int {
    return maxHP
  }

  private func setMaxHP() -> Int {
    return (2 * baseHP + hpIV + hpEV / 4) * level / 100 + level + 10
  }

  func takeDamage(_ amount: Int) -> Void {
    guard hp - amount >= 0 else {
      hp = 0
      fainted = true
      return
    }

    hp -= amount
  }

  func fullHeal() -> Void {
    hp = maxHP
  }

  func heal(_ amount: Int) -> Void {
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

  func getXP() -> Int {
    return xp
  }

  func getLevelUpXP() -> Int {
    return levelUpXP
  }

  private func setLevelUpXP() -> Int {
    switch xpGroup {
    case .erratic:
      switch level {
      case 1 ..< 50:
        return level ^^ 3 * (100 - level) / 50
      case 50 ..< 68:
        return level ^^ 3 * (150 - level) / 100
      case 68 ..< 98:
        return level ^^ 3 * (1911 - 10 * level) / 1500
      case 98 ... 100:
        return level ^^ 3 * (160 - level) / 100
      default:
        return Int.max
      }
    case .fast:
      return 4 * level ^^ 3 / 5
    case .mediumFast:
      return level ^^ 3
    case .mediumSlow:
      return level ^^ 3 * 6 / 5 - level ^^ 2 * 15 + level * 100 - 140
    case .slow:
      return 5 * level ^^ 3 / 4
    case .fluctuating:
      switch level {
      case 1 ..< 15:
        return level ^^ 3 * (level + 73) / 150
      case 15 ..< 36:
        return level ^^ 3 * (level + 14) / 50
      case 36 ... 100:
        return level ^^ 3 * (level + 64) / 100
      default:
        return Int.max
      }
    }
  }

  func increaseXP(_ amount: Int) -> Bool {
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
        levelUpXP = setLevelUpXP()
      }
    }

    return true
  }
}

// Configuration options for Ascend
struct AscendConfig {
  var activePokémon: Pokémon
}

// MARK: - Trainer info
struct Trainer {
  static var name = "George"
  static var currentLocation = GameMap.ascendLobby
  static var currentAction = "N/A"
  static var team: [Pokémon] = [Pokémon(model: "latios", nickname: "", shiny: false, level: 5, fainted: false, hpIV: 31, hpEV: 252, hp: 27, xp: 0)]
  
  static var ascend: AscendConfig = AscendConfig(activePokémon: team[0])
}
