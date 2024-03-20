//
//  GameViewController.swift
//  business
//
//  Created by Gustavo Munhoz Correa on 19/03/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetGameScene), for: .touchUpInside)
        resetButton.frame = CGRect(x: 300, y: 50, width: 100, height: 50)
        view.addSubview(resetButton)
        
        guard let skView = self.view as? SKView else {
            print("Could not cast the view to SKView.")
            return
        }
        
        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as? GameScene {
                sceneNode.scaleMode = .aspectFill
                
                skView.presentScene(sceneNode)
                skView.ignoresSiblingOrder = true
                
            }
        }
    }


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func resetGameScene() {
        if let view = self.view as! SKView? {
            if let scene = GKScene(fileNamed: "GameScene") {
                if let sceneNode = scene.rootNode as! GameScene? {
                    sceneNode.scaleMode = .aspectFill
                    
                    let transition = SKTransition.fade(withDuration: 0.4)
                    
                    view.presentScene(sceneNode, transition: transition)
                }
            }
            
            view.ignoresSiblingOrder = true
        }
    }
}

