//
//  WavePageControlTests.swift
//  WavePageControlTests
//
//  Created by Bogdan Chornobryvets on 21.08.2022.
//

import XCTest
@testable import WavePageControl

class WavePageControlTests: XCTestCase {
    func testMemoryReferencing() throws {
        //given
        let pageControl: UIWavePageControl = UIWavePageControl<String>(maxNavigationWidth: 300,
                                                                       defaultButtonHeight: 16,
                                                                       defaultSpacing: 16,
                                                                       minSpacing: 2)
        
        //when
        var strongCustomPageProvider: TestCustomWavePageViewProvider? = TestCustomWavePageViewProvider()
        weak var weakCustomPageProvider: TestCustomWavePageViewProvider? = strongCustomPageProvider
        
        //then
        pageControl.setDelegate(weakCustomPageProvider)
        XCTAssertNotNil(weakCustomPageProvider, "Error: UIWavePageControl did not save CustomWavePageViewProvider reference")
        strongCustomPageProvider = nil
        XCTAssertNil(weakCustomPageProvider, "Error: UIWavePageControl holds strong reference to the CustomWavePageViewProvider")
    }
    
    private class TestCustomWavePageViewProvider: WavePageControlDelegate {
        func createCustomPageView(for id: String) -> WavePageButtonView {
            DefaultPageButtonView()
        }
        func didSwipeScroll(_ wavePageControl: UIWavePageControl<String>, toPageWithId id: String, isGestureCompleted: Bool) {
            
        }
        func didTap(_ wavePageControl: UIWavePageControl<String>, onPageWithId id: String) {
            
        }
    }
}
