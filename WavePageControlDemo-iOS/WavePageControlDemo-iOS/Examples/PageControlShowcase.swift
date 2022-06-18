//
//  PageControlShowcase.swift
//  WavePageControlDemo-iOS
//
//  Created by Bogdan Chornobryvets on 24.08.2022.
//

import UIKit
import WavePageControl
import Combine

class PageControlShowcase: UIViewController {
    private let allowedChars: String = "abcdefghijklmnopqrstuvwxyz"
    @Published var pageIDs: [String] = []
    @Published var currentPage: String = ""
    private let pageControl = UIWavePageControl<String>()
    private var bucket = Set<AnyCancellable>()
    private let screenWidth = UIScreen.main.bounds.width * 0.8
    private let showExtraControls: Bool
    
    init(showExtraControls: Bool = true) {
        self.showExtraControls = showExtraControls
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 20
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vStack.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        let itemsLabel = UILabel()
        itemsLabel.translatesAutoresizingMaskIntoConstraints = false
        itemsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        itemsLabel.alpha = showExtraControls ? 1 : 0
        vStack.addArrangedSubview(itemsLabel)
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 100).isActive = true
        vStack.addArrangedSubview(separator)
        
        vStack.addArrangedSubview(pageControl)
        UIView.performWithoutAnimation {
            setupPageControl(pageControl)
            updatePageControl(pageControl, screenWidth: screenWidth)
            pageControl.layoutIfNeeded()
        }

        addButtons(to: vStack)
        
        let startPageIDs = randomChars()
        pageIDs = startPageIDs
        UIView.performWithoutAnimation {
            pageControl.pageIDs = startPageIDs
            itemsLabel.attributedText = self.attributedTitle(for: startPageIDs, selectedItem: "")
            pageControl.layoutIfNeeded()
            itemsLabel.layoutIfNeeded()
        }
        
        $pageIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPageIDs in
                guard let self = self else { return }
                itemsLabel.attributedText = self.attributedTitle(for: newPageIDs, selectedItem: self.pageControl.currentPage)
                itemsLabel.layoutIfNeeded()
                self.pageControl.pageIDs = newPageIDs
            }
            .store(in: &bucket)
        
        $currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCurrentPage in
                guard let self = self else { return }
                itemsLabel.attributedText = self.attributedTitle(for: self.pageControl.pageIDs, selectedItem: newCurrentPage)
                itemsLabel.layoutIfNeeded()
                self.pageControl.currentPage = newCurrentPage
            }
            .store(in: &bucket)
    }
    
    func setupPageControl(_ pageControl: UIWavePageControl<String>) {}
    func updatePageControl(_ pageControl: UIWavePageControl<String>, screenWidth: CGFloat) { }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updatePageControl(pageControl, screenWidth: size.width)
    }
    
    private func addButtons(to stack: UIStackView) {
        let buttonsStack = UIStackView()
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 30
        let addButton = getButton(withTitle: "Add", selector: #selector(addPagePressed))
        let removeButton = getButton(withTitle: "Remove", selector: #selector(removePagePressed))
        let customButton = getButton(withTitle: "Custom", selector: #selector(randomisePages))
        let throwActiveButton = getButton(withTitle: "< Move >", selector: #selector(moveActivePage))
        
        buttonsStack.addArrangedSubview(addButton)
        buttonsStack.addArrangedSubview(removeButton)
        buttonsStack.addArrangedSubview(customButton)
        if showExtraControls {
            buttonsStack.addArrangedSubview(throwActiveButton)
        }
        stack.addArrangedSubview(buttonsStack)
    }
    
    private func getButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    private func attributedTitle(for stringArray: [String], selectedItem: String?) -> NSAttributedString {
        let font = UIFont.monospacedSystemFont(ofSize: 20, weight: .bold)
        let attributedString = NSMutableAttributedString(string: stringArray.joined())
        attributedString.setAttributes([.font: font, .foregroundColor: UIColor.gray],
                                       range: NSRange(location: 0, length: attributedString.length))
        if let index = stringArray.firstIndex(of: selectedItem ?? "") {
            let range = NSRange(location: index,length: 1)
            attributedString.setAttributes([.font: font.withSize(25), .foregroundColor: UIColor.systemPink],
                                           range: range)
        }
        return attributedString
    }
    
    private func randomChars(length: Int? = nil) -> [String] {
        let length = length ?? Int.random(in: 5..<20)
        let slice = allowedChars.shuffled().map(String.init).prefix(length)
        return Array(slice)
    }
    
    private func removePage(at index: Int) {
        pageIDs.remove(at: index < pageIDs.count ? index : pageIDs.count - 1)
    }
    
    private func addPage(at index: Int) {
        guard let item = Set(allowedChars.map(String.init))
            .subtracting(Set(pageIDs))
            .randomElement() else { return }
        pageIDs.insert(item, at: index)
    }

    func vibrate() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension PageControlShowcase {
    @objc private func addPagePressed() {
        vibrate()
        let index = pageIDs.count > 0 ? Int.random(in: 0..<pageIDs.count) : 0
        addPage(at: index)
    }
    
    @objc private func removePagePressed() {
        vibrate()
        guard pageIDs.count > 0 else { return }
        removePage(at: Int.random(in: 0..<pageIDs.count))
    }
    
    @objc func randomisePages() {
        vibrate()
        pageIDs = randomChars()
    }
    
    @objc func moveActivePage() {
        guard let index = pageIDs.firstIndex(of: currentPage) else { return }
        let destinationIndex = (pageIDs.count - (index >= pageIDs.count / 2 ? 1 : 0)) - index
        pageIDs.move(fromOffsets: .init(integer: index), toOffset: .init(destinationIndex))
    }
}

fileprivate extension RandomAccessCollection {
    func unique<ID: Hashable>(by id: KeyPath<Element, ID>) -> [Element] {
        var seen: [ID: Bool] = [:]
        return self.filter {
            seen.updateValue(true, forKey: $0[keyPath: id]) == nil
        }
    }
}
