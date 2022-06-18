//
//  CustomPageControl.swift
//  WavePageControlDemo-iOS
//
//  Created by Bogdan Chornobryvets on 24.08.2022.
//

import SwiftUI
import WavePageControl

final class CustomPageControl: PageControlShowcase {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func setupPageControl(_ pageControl: UIWavePageControl<String>) {
        pageControl.setDelegate(self)
    }
    
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

extension CustomPageControl: WavePageControlDelegate {
    func createCustomPageView(for id: String) -> WavePageButtonView {
        
        //Default implementation of this delegate method is DefaultPageButtonView()
        
        //Here we are creating fully custom view for the page. Must inherit WavePageButtonView.
        CustomPageButtonView(with: id)
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
                    wavePageControl.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
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

//Custom page view must inherit WavePageButtonView
final class CustomPageButtonView: WavePageButtonView {
    private let accentColor: UIColor = .white
    private let transparentColor: UIColor = .black
    private var currentHeight: CGFloat? = nil
    private var isZoomed: Bool = false
    
    let label = UILabel()
    let infoView = UIView()
    var offsetConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    init(with text: String) {
        super.init()
        infoView.layer.borderColor = accentColor.cgColor
        infoView.backgroundColor = accentColor
        infoView.layer.borderWidth = 1
        infoView.translatesAutoresizingMaskIntoConstraints = false
        offsetConstraint = infoView.centerYAnchor.constraint(equalTo: centerYAnchor)
        widthConstraint = infoView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        heightConstraint = infoView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        label.textColor = .red
        label.alpha = 0
        infoView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            offsetConstraint,
            widthConstraint,
            heightConstraint
        ])
        zoomConstraints()
    }
    
    public override func didChangeHeight(to height: CGFloat) {
        let newHeight = isZoomed ? height * 1.6 / 2 : height / 4
        infoView.layer.cornerRadius = newHeight
    }
    
    public override func didChangeState(_ state: WavePageButtonState) {
        switch state {
        case .default:
            infoView.backgroundColor = transparentColor
            label.alpha = 0
            label.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            isZoomed = false
        case .active:
            infoView.backgroundColor = accentColor
            label.alpha = 1
            label.transform = CGAffineTransform(scaleX: 1, y: 1)
            isZoomed = true
        }
        zoomConstraints()
    }
    
    private func zoomConstraints() {
        offsetConstraint.constant = isZoomed ? -50 : 0
        widthConstraint = widthConstraint.setMultiplier(multiplier: isZoomed ? 1.6 : 1)
        heightConstraint = heightConstraint.setMultiplier(multiplier: isZoomed ? 2.5 : 1)
    }
    
}

fileprivate extension NSLayoutConstraint {
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let isActiveState = isActive
        isActive = false
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        if isActiveState {
            NSLayoutConstraint.activate([newConstraint])
        }
        return newConstraint
    }
}
