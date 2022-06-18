import XCTest
@testable import WavePageControl

final class ReshufflerTests: XCTestCase {
    
    func testReshuffler() throws {
        var optionalInitial: [String?] = randomChars(length: 1200)
        var optionaDesired: [String?] = randomChars(length: 800)
        let nilInsertions = (0..<Int.random(in: 0..<100)).map { _ in Int.random(in: 0..<optionalInitial.count) } + [optionalInitial.count]
        for index in nilInsertions {
            optionalInitial.insert(nil, at: index)
            let desiredindex = index < optionaDesired.count ? index : optionaDesired.count
            optionaDesired.insert(nil, at: desiredindex)
        }
        checkSequences(initial: optionalInitial,
                       desired: optionaDesired)
        
        checkSequences(initial: randomChars(length: 685),
                       desired: randomChars(length: 1760))
        
        checkSequences(initial: randomChars(length: 0),
                       desired: randomChars(length: 1100))
        
        checkSequences(initial: randomChars(length: 1100),
                       desired: randomChars(length: 0))
    }
    
    func testReshufflerPerformanceMorePages() {
        measure {
            checkSequences(initial: randomChars(length: 100),
                           desired: randomChars(length: 70))
        }
    }
    
    func testReshufflerPerformanceLessPages() {
        measure {
            checkSequences(initial: randomChars(length: 12),
                           desired: randomChars(length: 18))
        }
    }
    
    private func checkSequences(initial initialSequence: [String?], desired desiredSequence: [String?]) {
        print("--- test case ---")
        print("initialSequence count: \(initialSequence.count)")
        print("desiredSequence count: \(desiredSequence.count)")
        
        //when
        let reshuffler = Reshuffler(initialSequence: initialSequence)
        let strategy = reshuffler.shuffleStrategy(for: desiredSequence)
        
        var shufflingSequence = initialSequence
        for operation in strategy {
            switch operation {
            case let .reordering(map):
                for direction in map {
                    let element = shufflingSequence.remove(at: direction.from)
                    shufflingSequence.insert(element, at: direction.to)
                }
            case let .insertion(items):
                for item in items {
                    shufflingSequence.insert(item.element, at: item.offset)
                }
            case let .deletion(reversedIndices):
                for index in reversedIndices {
                    shufflingSequence.remove(at: index)
                }
            }
        }
        
        //then
        XCTAssertEqual(desiredSequence, shufflingSequence)
    }
    
    private func randomChars(length: Int) -> [String] {
        let allowedChars = "abcdefghijklmnopqrstuvwxyz"
        return (0..<length)
            .map { _ in String(allowedChars.randomElement()!) }
    }
}

