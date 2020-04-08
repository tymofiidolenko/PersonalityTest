//
//  AnswerDescription.swift
//  PersonalityTest
//
//  Created by Tymofii Dolenko on 07.04.2020.
//

import Foundation

public struct AnswerDescription {
    
    public typealias AnswerOption = String
    
    public struct NumberRange {
        var from: Int
        var to: Int
    }
    
    public struct Condition {
        
        public enum Predicate {
            case exactEquals([String])
        }
        
        public var predicate: Predicate
        public var ifPositive: Question?
    }
    
    public enum AnswerType {
        case singleChoice([AnswerOption])
        case numberRange(NumberRange)
        
        public var range: NumberRange? {
            get {
                guard case let .numberRange(value) = self else { return nil }
                return value
            }
            set {
                guard case .numberRange = self, let newValue = newValue else { return }
                self = .numberRange(newValue)
            }
        }
        
        public var options: [AnswerOption]? {
            get {
                guard case let .singleChoice(value) = self else { return nil }
                return value
            }
            set {
                guard case .singleChoice = self, let newValue = newValue else { return }
                self = .singleChoice(newValue)
            }
        }
    }
    
    var type: AnswerType
    var condition: Condition?
}

enum AnswerVerificationError: Error {
    case invalid
}

extension AnswerDescription {
    
    func verifyAnswer(_ answer: Answer) -> Result<Answer,Error> {
        
        switch type {
        case let .singleChoice(options):
            
            guard let option = answer.option else {
                return .failure(AnswerVerificationError.invalid)
            }
            
            guard options.contains(option) else {
                return .failure(AnswerVerificationError.invalid)
            }
            
            return .success(answer)
            
        case let .numberRange(range):
            
            guard var selectedRange = answer.range else {
                return .failure(AnswerVerificationError.invalid)
            }
            
            guard selectedRange.to <= range.to && selectedRange.from >= range.from else {
                return .success(.range(range))
            }
            
            guard selectedRange.from <= selectedRange.to else {
                selectedRange.to = selectedRange.from
                return .success(.range(selectedRange))
            }
            
            return .success(answer)
        }
    }
}
