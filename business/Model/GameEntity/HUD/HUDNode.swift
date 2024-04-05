//
//  HUDNode.swift
//  business
//
//  Created by Gustavo Munhoz Correa on 04/04/24.
//

import SpriteKit

class HUDNode: SKSpriteNode {

    var pauseButton: PauseButtonNode!
    var currentScoreLabel: SKLabelNode!
    var personalBestLabel: SKLabelNode!
    var crownSprite: SKSpriteNode!
    var nigiriCountLabel: SKLabelNode!
    var nigiriSprite: SKSpriteNode!
    
    func setup(withFrame frame: CGRect) {
        self.name = GC.HUD.HUD_NAME
        
        let t: CGAffineTransform = .init(scaleX: frame.width / 393, y: frame.height / 852)
        pauseButton = PauseButtonNode(imageNamed: "pauseButton", size: CGSize(width: 56, height: 46).applying(t))
        pauseButton.position = CGPoint(x: -frame.midX * 0.75, y: frame.midY * 0.82).applying(t)
        pauseButton.zPosition = 100
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
        
        currentScoreLabel = SKLabelNode(fontNamed: "Urbanist-Black")
        currentScoreLabel.fontSize = 36
        currentScoreLabel.fontColor = .white
        currentScoreLabel.horizontalAlignmentMode = .right
        currentScoreLabel.verticalAlignmentMode = .top
        currentScoreLabel.position = CGPoint(x: frame.midX * 0.9, y: pauseButton.position.y + 12).applying(t)
        currentScoreLabel.text = "0 m"
        currentScoreLabel.zPosition = 100
        addChild(currentScoreLabel)
        
        personalBestLabel = SKLabelNode(fontNamed: "Urbanist-Medium")
        personalBestLabel.fontSize = 15
        personalBestLabel.fontColor = .white
        personalBestLabel.horizontalAlignmentMode = .right
        personalBestLabel.verticalAlignmentMode = .top
        personalBestLabel.text = "\(GameManager.shared.personalBestScore) m"
        personalBestLabel.zPosition = 100
        personalBestLabel.position = CGPoint(x: currentScoreLabel.position.x, y: currentScoreLabel.position.y * 0.9).applying(t)
        
        let crownTexture = SKTexture(imageNamed: "crown.fill")
        crownSprite = SKSpriteNode(texture: crownTexture, size: CGSize(width: 13, height: 13).applying(t))
        crownSprite.zPosition = 100
        crownSprite.position = CGPoint(x: personalBestLabel.frame.minX - crownSprite.frame.width, y: personalBestLabel.frame.midY).applying(t)
        
        addChild(personalBestLabel)
        addChild(crownSprite)
        
        
        nigiriCountLabel = SKLabelNode(fontNamed: "Urbanist-Black")
        nigiriCountLabel.fontSize = 32
        nigiriCountLabel.fontColor = .white
        nigiriCountLabel.text = "00"
        nigiriCountLabel.position = CGPoint(x: personalBestLabel.position.x * 0.9, y: personalBestLabel.position.y * 0.81)
        nigiriCountLabel.zPosition = 100
        addChild(nigiriCountLabel)
        
        nigiriSprite = SKSpriteNode(imageNamed: "nigiri_score")
        nigiriSprite.size = CGSize(width: 56, height: 38).applying(t)
        nigiriSprite.position = CGPoint(x: nigiriCountLabel.frame.minX - nigiriSprite.frame.width/2, y: nigiriCountLabel.frame.midY).applying(t)
        nigiriSprite.zPosition = 100
        addChild(nigiriSprite)
    }
    
    func updateCurrentScore(_ score: Int) {
        currentScoreLabel.text = "\(score) m"
    }
}