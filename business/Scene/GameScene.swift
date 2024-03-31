//
//  GameScene.swift
//  business
//
//  Created by Gustavo Munhoz Correa on 19/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var hasStarted = false
    
    var cameraManager: CameraManager!
    
    var touchStart: CGPoint?
    
    var wallFactory: WallFactory!
    var existingWalls: [WallNode] = []
    var lastWallTopY: CGFloat!
    
    var catEntity: CatEntity!
    var cucumberEntity: CucumberEntity!
    var lastUpdateTime: TimeInterval = 0
    var startingHeight: CGFloat!
    
    var arrowNode: ArrowNode?
    
    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "bg")!
        physicsWorld.gravity = GC.GRAVITY
        physicsWorld.contactDelegate = self
            
        cameraManager = CameraManager(frame: frame)
        self.camera = cameraManager.cameraNode
        
        wallFactory = WallFactory(frame: frame, cameraPositionY: cameraManager.cameraNode.position.y)
        
        let initialWalls = wallFactory.createInitialWalls()
        
        catEntity = CatEntity(size: CGSize(width: 98, height: 141))
        
        if let catNode = catEntity.component(ofType: CatSpriteComponent.self)?.node {
            catNode.position = CGPoint(x: frame.midX - 50, y: -frame.height * 0.25)
            catNode.zPosition = 2
            addChild(catNode)
        }
        
        cucumberEntity = CucumberEntity(size: CGSize(width: 120, height: 165))
        if let cucumberNode = cucumberEntity.component(ofType: CucumberSpriteComponent.self)?.node {
            cucumberNode.position = CGPoint(x: frame.minX + 50, y: -frame.height * 0.5)
            cucumberNode.zPosition = 5
            addChild(cucumberNode)
        }
        
        addChild(cameraManager.cameraNode)
        
        for wall in initialWalls {
            existingWalls.append(wall)
            addChild(wall)
        }
        
        handleWallGeneration()
        
        // Needed for cat standing still at startup
        catEntity.prepareForJump()
        
        startingHeight = catEntity.spriteComponent.node.position.y
        catEntity.agentComponent.setPosition(catEntity.spriteComponent.node.position)
        cucumberEntity.agentComponent.setPosition(cucumberEntity.spriteComponent.node.position)
    }

    
    // MARK: - Default methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStart = touch.location(in: cameraManager.cameraNode)
        
        guard catEntity.spriteComponent.currentWallMaterial != .none else { return }
        
        createArrowNode()
        catEntity.prepareForJump()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = touchStart else { return }
        let touchLocation = touch.location(in: cameraManager.cameraNode)
        
        arrowNode?.update(start: start, end: touchLocation)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = touchStart else { return }
        
        if !hasStarted { hasStarted = true }
        
        let location = touch.location(in: cameraManager.cameraNode)
        
        catEntity.handleJump(from: start, to: location)
        
        arrowNode?.removeFromParent()
        arrowNode = nil
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        cameraManager.updateCameraPosition(catEntity: catEntity)
        
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        if hasStarted { handleCucumberMovement(currentTime: currentTime) }
        
        guard catEntity.spriteComponent.node.physicsBody?.velocity != .zero else { return }
        
        catEntity.handleMovement(startingHeight: startingHeight, walls: existingWalls)
        
        handleWallGeneration()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let (bodyA, bodyB) = (contact.bodyA, contact.bodyB)
        
        if bodyA.node?.name == "cat" && bodyB.node?.name == "enemyCucumber"
            || bodyA.node?.name == "enemyCucumber" && bodyB.node?.name == "cat"
        {
            cucumberEntity.isJumpingAtPlayer = false
            GameManager.shared.resetGame()
        }
    }
    
    // MARK: - Custom methods
    func handleWallGeneration() {
        wallFactory.adjustWallParameters(forProgress: catEntity.calculateProgress())
        
        if cameraManager.cameraNode.position.y * cameraManager.currentScale + (frame.size.height * 0.5) > wallFactory.lastWallMaxY {
            let walls = wallFactory.createWalls()
            
            for wall in walls {
                existingWalls.append(wall)
                wall.zPosition = 1
                addChild(wall)
            }
        }
    }
    
    func handleCucumberMovement(currentTime: TimeInterval) {
        if let vy = catEntity.spriteComponent.node.physicsBody?.velocity.dy, vy < -2000 {
            cucumberEntity.jumpAtPlayer(player: catEntity)
            
        } else if !cucumberEntity.isJumpingAtPlayer {
            cucumberEntity.updateTarget(catEntity.agentComponent.agent)
            var deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            if deltaTime > 0.02 {
                deltaTime = 0.02
            }
            
            cucumberEntity.agentComponent.agent.update(deltaTime: deltaTime)
            catEntity.agentComponent.agent.update(deltaTime: deltaTime)
        }
    }
    
    private func createArrowNode() {
        arrowNode = ArrowNode(
            catPosition: CGPoint(
                x: catEntity.spriteComponent.node.position.x,
                y: catEntity.spriteComponent.node.position.y + catEntity.spriteComponent.node.frame.height/2
            )
        )
        
        addChild(arrowNode!)
    }
}
