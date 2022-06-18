//
//  DefaultPageControl.swift
//  WavePageControlDemo-iOS
//
//  Created by Bogdan Chornobryvets on 24.08.2022.
//

import SwiftUI
import WavePageControl

final class DefaultPageControl: PageControlShowcase {
    //WavePageControl setup example
    override func updatePageControl(_ pageControl: UIWavePageControl<String>, screenWidth: CGFloat) {
        //MARK: You can change UIWavePageControl parameters
        let screenWidth = screenWidth * 0.8
        let itemHeight = min(screenWidth / 10, 50)
        
        pageControl.maxNavigationWidth = screenWidth
        pageControl.defaultButtonHeight = itemHeight
        pageControl.defaultSpacing = itemHeight
        pageControl.minSpacing = screenWidth / 140
        pageControl.updateLayout() //Will animate to the new layout
    }
}
