//
//  Utils.swift
//  
//
//  Created by Bogdan Chornobryvets on 21.08.2022.
//

import UIKit

internal struct UIConstants {
    static func shortAnimation(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: animations, completion: { (completed) in
            completion?(completed)
        })
    }
}

internal extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}
