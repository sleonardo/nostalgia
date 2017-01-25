//
//  HomeController.swift
//  nostalgia
//
//  Created by George Lim on 2016-07-01.
//  Copyright © 2016 George Lim. All rights reserved.
//

import SpriteKit

class HomeController: UIViewController {

  override func loadView() -> Void {
    self.view = SKView()
  }

  override func viewDidLoad() -> Void {
    super.viewDidLoad()
  }

  override func viewWillLayoutSubviews() -> Void {
    super.viewWillLayoutSubviews()

    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true

    let scene = AscendGame(size: skView.bounds.size)
    scene.scaleMode = .aspectFill

    skView.presentScene(scene)
  }

  override var prefersStatusBarHidden : Bool {
    return true
  }
}
