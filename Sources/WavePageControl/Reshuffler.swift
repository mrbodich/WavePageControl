//
//  Reshuffler.swift
//  
//
//  Created by Bogdan Chornobryvets on 23.07.2022.
//

import Foundation

internal struct Reshuffler<Element: Comparable> {
    let initialSequence: [Element?]
    
    func shuffleStrategy(for newItems: [Element?]) -> [Operation] {
        
        var newItemsMap = newItems.map { (isMarked: false, item: $0) }
        let removed = initialSequence.enumerated()
            .filter { oldItem in
                if let index = newItemsMap.firstIndex(where: { $0 == (false, oldItem.element) }) {
                    newItemsMap[index].isMarked = true
                    return false
                }
                return true
            }
        
        var oldItemsMap = initialSequence.map { (isMarked: false, item: $0) }
        var noNewItems = newItems
            .filter { newItem in
                if let index = oldItemsMap.firstIndex(where: { $0 == (false, newItem) }) {
                    oldItemsMap[index].isMarked = true
                    return true
                }
                return false
            }

        for ghost in removed {
            noNewItems.insert(ghost.element, at: ghost.offset)
        }
        
        var mutableOld = initialSequence
        var replaced: [(from: Int, to: Int)] = []
        
        for n in 0..<noNewItems.count {
            let o = Array(mutableOld.enumerated())
                .firstIndex { offset, element in
                        element == noNewItems[n] &&
                        offset >= n
                }!
            if o != n {
                replaced.append((from: o, to: n))
                let element = mutableOld.remove(at: o)
                mutableOld.insert(element, at: n)
            }
        }
        
        var mutableRemoved = removed
        var insertions: [(offset: Int, element: Element?)] = []
        for n in 0..<newItems.count {
            let removedIndices = mutableRemoved.map { $0.offset }
            let insertIndex = shiftedIndex(n, pushingIndices: removedIndices, isInserting: true)
            let compareIndex = shiftedIndex(n, pushingIndices: removedIndices, isInserting: false)
            if compareIndex >= mutableOld.count || mutableOld[compareIndex] != newItems[n] {
                insertions.append((offset: insertIndex, element: newItems[n]))
                mutableOld.insert(newItems[n], at: insertIndex)
                for r in 0..<mutableRemoved.count where insertIndex <= mutableRemoved[r].offset {
                    mutableRemoved[r].offset += 1
                }
            }
        }
        
        for (offset, _) in mutableRemoved.reversed() {
            mutableOld.remove(at: offset)
        }
        
        return [
            .reordering(map: replaced),
            .insertion(items: insertions),
            .deletion(reversedIndices: mutableRemoved.map { $0.offset }.reversed())
        ]
        
    }
    
    private func shiftedIndex(_ index: Int, pushingIndices: [Int], isInserting: Bool) -> Int {
        var shiftedIndex = index
        var baseShift = 0
        var shift = 0
        if isInserting {
            repeat {
                baseShift = shift
                shift = pushingIndices.filter { $0 < (shiftedIndex + baseShift) }.count
            } while shift != baseShift
        } else {
            repeat {
                baseShift = shift
                shift = pushingIndices.filter { $0 <= (shiftedIndex + baseShift) }.count
            } while shift != baseShift
        }
        shiftedIndex += baseShift
        
        return shiftedIndex
    }
    
    enum Operation {
        case reordering(map: [(from: Int, to: Int)])
        case insertion(items: [(offset: Int, element: Element?)])
        case deletion(reversedIndices: [Int])
    }
}

