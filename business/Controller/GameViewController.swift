//
//  GameViewController.swift
//  business
//
//  Created by Gustavo Munhoz Correa on 19/03/24.
//

import UIKit
import SpriteKit
import GameplayKit
import Combine
import GoogleMobileAds

class GameViewController: AdViewController {
    private var cancellables = Set<AnyCancellable>()
    private var gameView = GameView()
    
    override func loadView() {
        view = gameView
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscriptions()
        
        Task {
            await AdMobService.loadInterstitialAd(inAVC: self)
            await AdMobService.loadRewardedAd(inAVC: self)
            AdMobService.loadBannerAd(inAVC: self)
        }
        
        guard !UserDefaults.standard.bool(forKey: UserDefaultsKeys.areAdsRemoved) else { return }
        
        DispatchQueue.main.async {
            let viewWidth = UIScreen.main.bounds.inset(by: self.view.safeAreaInsets).width
            let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
            self.bannerView = GADBannerView(adSize: adaptiveSize)
            
            if let bannerView = self.bannerView {
                self.addBannerViewToView(bannerView)
            } else {
                AdMobService.loadBannerAd(inAVC: self)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        gameView.setupSKScene()
        
        if let view = self.view as? GameOverView {
            view.setupAnimations()
        }
    }
    
    func setupSubscriptions() {
        GameManager.shared.shouldPause.sink { [weak self] shouldPause in
            if shouldPause {
                self?.view = PauseView(
                    frame: UIScreen.main.bounds,
                    currentScore: GameManager.shared.currentScore.value
                )
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldResume.sink { [weak self] shouldResume in
            if shouldResume {
                self?.view = self?.gameView
                self?.gameView.skView.scene?.isPaused = false
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldEnd.sink { [weak self] shouldEnd in
            if shouldEnd {
                self?.view = GameOverView(
                    isHighscore: GameManager.shared.personalBestScore < GameManager.shared.currentScore.value,
                    frame: UIScreen.main.bounds
                )
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldReset.sink { [weak self] shouldReset in
            if shouldReset {
                self?.view = self?.gameView
                self?.resetGameScene()
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldShowRewardAd.sink { [weak self] shouldShowRewardAd in
            if shouldShowRewardAd {
                AudioManager.shared.pauseBackgroundMusic()
                
                if let self = self { AdMobService.showRewardedAd(atAVC: self) }
                
                if let view = self?.view as? GameOverView {
                    view.nigiriCountLabel.textColor = .menuYellow
                    view.rewardedAdButton.alpha = 0
                    view.rewardedAdButton.isUserInteractionEnabled = false
                    view.rotatingStarContainer.alpha = 0
                }
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldShowIntersticialAd.sink { [weak self] shouldShowIntersticialAd in
            if shouldShowIntersticialAd {
                AudioManager.shared.pauseBackgroundMusic()
                if let self = self { AdMobService.showInterstitialAd(atAVC: self) }
            }
        }
        .store(in: &cancellables)
        
        GameManager.shared.shouldPopToMenuViewController.sink { [weak self] shouldPopToMenu in
            if shouldPopToMenu {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        .store(in: &cancellables)
    }
}

extension GameViewController {
    @objc func resetGameScene() {
        gameView.skView.presentScene(nil)
        
        let newGameScene = GameScene(size: gameView.skView.bounds.size)
        newGameScene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(withDuration: 0.4)
        gameView.skView.presentScene(newGameScene, transition: transition)
    }
}
