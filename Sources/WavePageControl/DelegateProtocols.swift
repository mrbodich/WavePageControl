//
//  DelegateProtocols.swift
//  
//
//  Created by Bogdan Chornobryvets on 21.08.2022.
//

import Foundation

public protocol WavePageControlDelegate: AnyObject {
    associatedtype ID: Comparable
    func createCustomPageView(for id: ID) -> WavePageButtonView
    func didSwipeScroll(_ wavePageControl: UIWavePageControl<ID>, toPageWithId id: ID, isGestureCompleted: Bool)
    func didTap(_ wavePageControl: UIWavePageControl<ID>, onPageWithId id: ID)
}

public extension WavePageControlDelegate {
    func createCustomPageView(for id: ID) -> WavePageButtonView {
        DefaultPageButtonView()
    }
    
    func didSwipeScroll(_ wavePageControl: UIWavePageControl<ID>, toPageWithId id: ID, isGestureCompleted: Bool) {
        wavePageControl.currentPage = id
    }
    
    func didTap(_ wavePageControl: UIWavePageControl<ID>, onPageWithId id: ID) {
        wavePageControl.currentPage = id
    }
}

final internal class AnyWavePageControlDelegate<ID: Comparable>: WavePageControlDelegate {
    let _createCustomPageView: (_ id: ID) -> WavePageButtonView
    let _didSwipeScroll: (_ wavePageControl: UIWavePageControl<ID>, _ id: ID, _ isGestureCompleted: Bool) -> ()
    let _didTap: (_ wavePageControl: UIWavePageControl<ID>, _ id: ID) -> ()

    init<Delegate: WavePageControlDelegate>(from delegate: Delegate) where Delegate.ID == ID {
        _createCustomPageView = { [weak delegate] id in
            delegate?.createCustomPageView(for: id) ?? DefaultPageButtonView()
        }
        _didSwipeScroll = { [weak delegate] pageControl, id, isGestureCompleted in
            delegate?.didSwipeScroll(pageControl, toPageWithId: id, isGestureCompleted: isGestureCompleted)
        }
        _didTap = { [weak delegate] pageControl, id in
            delegate?.didTap(pageControl, onPageWithId: id)
        }
    }
    
    public func createCustomPageView(for id: ID) -> WavePageButtonView {
        _createCustomPageView(id)
    }

    public func didSwipeScroll(_ wavePageControl: UIWavePageControl<ID>, toPageWithId id: ID, isGestureCompleted: Bool) {
        _didSwipeScroll(wavePageControl, id, isGestureCompleted)
    }
    
    func didTap(_ wavePageControl: UIWavePageControl<ID>, onPageWithId id: ID) {
        _didTap(wavePageControl, id)
    }
}
