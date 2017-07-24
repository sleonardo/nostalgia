//
//  Landscape.swift
//  nostalgia
//
//  Created by George Lim on 2017-05-07.
//  Copyright © 2017 George Lim. All rights reserved.
//

import UIKit

struct Landscape {
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
    
    animatingNodes = ["env_background", "env_trees_d", "env_trees_c", "env_trees_b", "env_trees_a1", "env_ground"]
    animatingNodeSpeeds = [0.1 * spriteScale, 0.25 * spriteScale, 0.5 * spriteScale, 1 * spriteScale, 2 * spriteScale, 12 * spriteScale]
    
    groundHeight = 110 * spriteScale
    skyCenter = (sceneHeight + groundHeight) / 2
  }
}
