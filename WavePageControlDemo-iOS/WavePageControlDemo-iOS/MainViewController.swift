//
//  ViewController.swift
//  WavePageControlDemo-iOS
//
//  Created by Bogdan Chornobryvets on 18.06.2022.
//

import UIKit
import SwiftUI
import Combine
import WavePageControl

class MainViewController: UINavigationController {
    var bucket = Set<AnyCancellable>()
    let pageControls: [(description: String, vc: PageControlShowcase)] = [
        ("Default", DefaultPageControl(showExtraControls: false)),
        ("Simple", SimplePageControl()),
        ("Custom", CustomPageControl())
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let baseVC = UIViewController()
        baseVC.view.backgroundColor = .white
        pushViewController(baseVC, animated: false)
        
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        baseVC.view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: baseVC.view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: baseVC.view.centerYAnchor)
        ])

        for destination in pageControls.enumerated() {
            vStack.addArrangedSubview(presentingButton("Show \(destination.element.description)", vcIndex: destination.offset))
        }
    }
    
    private func presentingButton(_ title: String, vcIndex: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = vcIndex
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        self.pushViewController(pageControls[sender.tag].vc, animated: true)
    }
    
}

//MARK: - SwiftUI

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainViewController {
        MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
        
    }
}

#if DEBUG
struct MainViewControllerRepresentable_Preview: PreviewProvider {
    static var previews: some View {
        MainViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
