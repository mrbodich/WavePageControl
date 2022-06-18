//
//  WavePageControl.swift
//
//
//  Created by Bogdan Chornobryvets on 18.06.2022.
//  Copyright © 2022 Bogdan Chornobryvets. All rights reserved.
//

import UIKit

public final class UIWavePageControl<ID: Comparable>: UIStackView {
    
    private var heightConstraint: NSLayoutConstraint!
    public var defaultButtonHeight: CGFloat
    public var defaultSpacing: CGFloat
    public var minSpacing: CGFloat
    public var maxNavigationWidth: CGFloat
    
    private var delegate: AnyWavePageControlDelegate<ID>?
    private let defaultDelegate = DefaultWavePageViewDelegate<ID>()
    private let defaultAnyDelagate: AnyWavePageControlDelegate<ID>
    private var currentDelegate: AnyWavePageControlDelegate<ID> {
        delegate ?? defaultAnyDelagate
    }

    public init(maxNavigationWidth: CGFloat = 200, defaultButtonHeight: CGFloat = 16, defaultSpacing: CGFloat = 16, minSpacing: CGFloat = 4) {
        defaultAnyDelagate = AnyWavePageControlDelegate(from: defaultDelegate)
        self.maxNavigationWidth = maxNavigationWidth
        self.defaultButtonHeight = defaultButtonHeight
        self.defaultSpacing = defaultSpacing
        self.minSpacing = minSpacing
        
        super.init(frame: .zero)
        heightConstraint = heightAnchor.constraint(equalToConstant: defaultButtonHeight)
        spacing = defaultSpacing
        alignment = .center
        distribution = .equalSpacing
        contentMode = .scaleToFill
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pagesNavigationDidScroll(recognizer:)))
        self.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pagesNavigationDidTap(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    public func setDelegate<Delegate: WavePageControlDelegate>(_ delegate: Delegate?) where Delegate.ID == ID {
        if let delegate = delegate {
            self.delegate = AnyWavePageControlDelegate(from: delegate)
        } else {
            self.delegate = nil
        }
    }

    public var pageIDs = [ID]() {
        didSet {
            guard pageIDs != oldValue, superview != nil else { return }
            buildButtons()
        }
    }
    
    public var currentPage: ID? {
        didSet {
            guard currentPage != oldValue, superview != nil else { return }
            updateCurrentPage()
        }
    }
    
    private func buildButtons() {
        let initialSequence: [ID?] = allPages.map { $0.isRemoved ? nil : $0.getID() }
        var targetSequence: [ID?] = pageIDs
        for item in initialSequence.enumerated() where item.element == nil {
            let offset = item.offset < targetSequence.count ? item.offset : targetSequence.count
            targetSequence.insert(nil, at: offset)
        }

        let reshuffler = Reshuffler(initialSequence: initialSequence)
        let strategy = reshuffler.shuffleStrategy(for: targetSequence)
        
        var newButtons: [WavePageButtonView] = []
        
        for operation in strategy {
            switch operation {
            case let .reordering(map):
                for (from, to) in map {
                    self.movePage(from: from, to: to)
                }
                //Animate items reordering
                UIConstants.shortAnimation {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            case let .insertion(items):
                for (offset, element) in items {
                    if let element = element {
                        newButtons.append(addPage(id: element, at: offset))
                    }
                }
                //Layout still hidden items to the correct position in UIStackView
                self.setNeedsLayout()
                self.layoutIfNeeded()
            case let .deletion(reversedIndices):
                for index in reversedIndices {
                    deletePage(at: index)
                }
                UIConstants.shortAnimation {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            }
        }
        
        newButtons.forEach {
            $0.isHidden = false
        }
        //Will animate later
        updateCurrentPage()
    }
    
    private func updateCurrentPage() {
        for button in pages {
            switch button.getID() == currentPage {
            case true:
                button.isActive = true
                bringSubviewToFront(button)
            case false:
                button.isActive = false
            }
        }
        updateLayout()
    }
    
    public func updateLayout() {
        heightConstraint.constant = defaultButtonHeight
        let pagesCount = pages.count
        var targetSpacing = ( maxNavigationWidth - defaultButtonHeight * CGFloat(pagesCount) ) / CGFloat( pagesCount - 1 )
        let dif = (defaultSpacing - targetSpacing) * 0.67
        targetSpacing = defaultSpacing - dif
        targetSpacing = targetSpacing > minSpacing ? targetSpacing : minSpacing
        switch targetSpacing {
        case let spacing where spacing >= defaultSpacing:
            self.spacing = defaultSpacing
            for button in pages { button.height = defaultButtonHeight } //Set default buttons height
        default:
            spacing = targetSpacing
            switch pages.firstIndex(where: { $0.isActive }) {
            case let.some(activeIndex):
                rebuildButtonsSizes(with: activeIndex)
            case .none:
                distributeBuuttonsEvenly()
            }
        }
        UIConstants.shortAnimation {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    private func rebuildButtonsSizes(with activeIndex: Int) {
        let halfWaveCount = 5
        let pagesCount = pages.count
        let maxWidth = maxNavigationWidth - spacing * CGFloat( pagesCount - 1 )
        let angleSegment = CGFloat.pi / CGFloat( halfWaveCount - 1 )
        var alphaFactors: [CGFloat] = []
        for index in 0..<pagesCount {
            let distanceToActive = abs(activeIndex - index)
            let alphaFactor: CGFloat
            switch distanceToActive {
            case 1...(halfWaveCount - 2):
                alphaFactor = 0.5 * cos(angleSegment * CGFloat(distanceToActive) - CGFloat.pi) + 0.5
            case 0:
                alphaFactor = 0.0
            default:
                alphaFactor = 1.0
            }
            alphaFactors.append(alphaFactor)
        }
        let averageAlphaFactor = alphaFactors.reduce(0, +) / CGFloat(alphaFactors.count)
        
        let topExp = CGFloat(pagesCount) * defaultButtonHeight - maxWidth
        let bottomExp = averageAlphaFactor * CGFloat(pagesCount) * defaultButtonHeight
        let xFactorDif =  topExp / bottomExp
        
        let personalXFactors = alphaFactors.map { 1 - $0 * xFactorDif }
        
        for (index, button) in pages.enumerated() {
            button.height = defaultButtonHeight * personalXFactors[index]
        }
    }
    
    private func distributeBuuttonsEvenly() {
        let pagesCount = pages.count
        let maxWidth = maxNavigationWidth - spacing * CGFloat( pagesCount - 1 )
        let buttonHeight = maxWidth / CGFloat(pagesCount)
        pages.forEach {
            $0.height = buttonHeight
        }
    }
    
    private var allPages: [WavePageButtonView] {
        arrangedSubviews
            .compactMap{ $0 as? WavePageButtonView }
    }
    
    private var pages: [WavePageButtonView] {
        allPages.filter { !$0.isRemoved }
    }
    
    private func movePage(from fromIndex: Int, to toIndex: Int) {
        let button = allPages[fromIndex]
        self.removeArrangedSubview(button)
        self.insertArrangedSubview(button, at: toIndex)
    }

    private func addPage(id: ID, at index: Int) -> WavePageButtonView {
        let button = currentDelegate.createCustomPageView(for: id)
        button.setup(id: id, withHeight: 0)
        self.insertArrangedSubview(button, at: index)
        return button
    }
    
    private func deletePage(at index: Int) {
        let page = allPages[index]
        page.isRemoved = true
        UIConstants.shortAnimation {
            page.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            page.isHidden = true
        } completion: { _ in
            page.removeFromSuperview()
        }
    }

    private func deletePage(withId id: ID) {
        guard let page = pages.first(where: { $0.getID() == id }) else { return }
        page.isRemoved = true
        UIConstants.shortAnimation {
            page.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            page.isHidden = true
        } completion: { _ in
            page.removeFromSuperview()
        }
    }
    
    public override func didMoveToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.constant = defaultButtonHeight
        heightConstraint.isActive = true
        UIView.performWithoutAnimation {
            spacing = defaultSpacing
            buildButtons()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.insetBy(dx: -bounds.width, dy: -bounds.height).contains(point)
    }
    
    @objc func pagesNavigationDidScroll(recognizer: UIPanGestureRecognizer) {
        let isGestureCompleted = ![.began, .changed].contains(recognizer.state)
        
        let count = pages.count
        let location = recognizer.location(in: self).x
        var index = Int( location / ( self.bounds.width / CGFloat(count) ) )
        index = index < 0 ? 0 : ( index >= count ? count - 1 : index )
        if let id = pageIDs[optional: index] {
            currentDelegate.didSwipeScroll(self, toPageWithId: id, isGestureCompleted: isGestureCompleted)
        }
    }
    
    @objc func pagesNavigationDidTap(recognizer: UIPanGestureRecognizer) {
        let midLocation = { (view: UIView) -> CGFloat in recognizer.location(in: view).x - view.frame.width / 2 }
        let selectedPage = pages.min { midLocation($0).magnitude < midLocation($1).magnitude }
        if let selectedID: ID = selectedPage?.getID() {
            currentDelegate.didTap(self, onPageWithId: selectedID)
        }
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate final class DefaultWavePageViewDelegate<ID: Comparable>: WavePageControlDelegate {
    func didSwipeScroll(_ wavePageControl: UIWavePageControl<ID>, toPageWithId id: ID, isGestureCompleted: Bool) {
        wavePageControl.currentPage = id
    }
}

open class WavePageButtonView: UIView {
    private var heightConstraint: NSLayoutConstraint!
    private var id: Any!
    fileprivate var isRemoved: Bool = false
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        alpha = 0
    }
    
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        alpha = 0
    }
    
    fileprivate func setup<ID: Comparable>(id: ID, withHeight height: CGFloat) {
        self.id = id
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
    }
    
    fileprivate func getID<ID: Comparable>() -> ID {
        return id as! ID
    }
    
    fileprivate var height: CGFloat = 0 {
        didSet {
            UIConstants.shortAnimation { [self] in
                heightConstraint.constant = height
                didChangeHeight(to: height)
                layoutIfNeeded()
            }
        }
    }
    
    open func didChangeHeight(to height: CGFloat) {
        
    }
    
    open func didChangeState(_ state: WavePageButtonState) {
        
    }
    
    public override var isHidden: Bool {
        didSet {
            switch isHidden {
            case false:
                alpha = 1
                updateState()
            case true:
                alpha = 0
            }
        }
    }
    
    fileprivate var isActive: Bool! = nil {
        didSet {
            guard let isActive = isActive, isActive != oldValue else { return }
            UIConstants.shortAnimation { [weak self] in
                self?.updateState()
            }
        }
    }
    
    private func updateState() {
        guard let isActive = isActive else { return }
        let state: WavePageButtonState = isActive ? .active : .default
        didChangeState(state)
    }
    
    open override func didMoveToSuperview() {
        NSLayoutConstraint.activate([
            heightConstraint,
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
        isActive = false
    }
    
    public enum WavePageButtonState {
        case `default`, active
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

public final class DefaultPageButtonView: WavePageButtonView {
    private let accentColor: UIColor
    private let defaultColor: UIColor
    
    public init(accentColor: UIColor = .yellow, defaultColor: UIColor = .white.withAlphaComponent(0.5), dotBorderColor: UIColor = .black, borderWidth: CGFloat = 1) {
        self.accentColor = accentColor
        self.defaultColor = defaultColor
        
        super.init()
        layer.borderColor = dotBorderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    public override func didChangeHeight(to height: CGFloat) {
        layer.cornerRadius = height / 2
    }
    
    public override func didChangeState(_ state: WavePageButtonState) {
        switch state {
        case .default:
            self.backgroundColor = defaultColor
            alpha = 0.5
        case .active:
            self.backgroundColor = accentColor
            alpha = 1
        }
    }
}
