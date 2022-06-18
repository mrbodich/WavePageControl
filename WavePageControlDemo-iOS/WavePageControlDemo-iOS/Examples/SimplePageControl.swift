//
//  SimplePageControl.swift
//  WavePageControlDemo-iOS
//
//  Created by Bogdan Chornobryvets on 24.08.2022.
//

import SwiftUI
import WavePageControl

final class SimplePageControl: PageControlShowcase {
    override func setupPageControl(_ pageControl: UIWavePageControl<String>) {
        pageControl.setDelegate(self)
    }
    
    //WavePageControl setup example
    override func updatePageControl(_ pageControl: UIWavePageControl<String>, screenWidth: CGFloat) {
        //MARK: You can change UIWavePageControl parameters
        let screenWidth = screenWidth * 0.8
        let itemHeight = min(screenWidth / 9, 55)
        
        pageControl.maxNavigationWidth = screenWidth
        pageControl.defaultButtonHeight = itemHeight
        pageControl.defaultSpacing = itemHeight
        pageControl.minSpacing = screenWidth / 140
        pageControl.updateLayout() //Will animate to the new layout
    }
}

extension SimplePageControl: WavePageControlDelegate {
    func createCustomPageView(for id: String) -> WavePageButtonView {
        
        //Default implementation of this delegate method is DefaultPageButtonView()
        
        DefaultPageButtonView(accentColor: .green,
                              defaultColor: .green.withAlphaComponent(0.2),
                              dotBorderColor: .gray,
                              borderWidth: 2)
    }
    
    func didSwipeScroll(_ wavePageControl: UIWavePageControl<String>, toPageWithId id: String, isGestureCompleted: Bool) {
        
        //You can simply set current page.
        //Next row is a default implementation of this delegate method.
        //wavePageControl.currentPage = id
        
        if currentPage != id {
            currentPage = id
            vibrate()
        }
        //Animate Page Control size
        switch isGestureCompleted {
        case false:
            if wavePageControl.transform == .identity {
                UIView.animate(withDuration: 0.3) {
                    wavePageControl.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            }
        case true:
            UIView.animate(withDuration: 0.3) {
                wavePageControl.transform = .identity
            }
        }
    }
    
    func didTap(_ wavePageControl: UIWavePageControl<String>, onPageWithId id: String) {
        
        //You can simply set current page.
        //Next row is a default implementation of this delegate method.
        //wavePageControl.currentPage = id
        
        if currentPage != id {
            currentPage = id
            vibrate()
        }
    }
}
