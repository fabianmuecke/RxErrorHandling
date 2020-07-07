//
//  TreatableSequence.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

public struct TreatableSequence<Trait, Element, Failure: Swift.Error> {
    let source: Observable<Element>

    init<O: ObservableConvertibleType>(raw: O) where O.Element == Element {
        source = raw.asObservable()
    }
}

extension TreatableSequence: ObservableConvertibleType {
    public func asObservable() -> Observable<Element> {
        source
    }
}

extension TreatableSequence: TreatableSequenceType {
    public var treatableSequence: TreatableSequence<Trait, Element, Failure> {
        self
    }

    public func asObservableResult() -> Observable<Result<Element, Failure>> {
        asObservable().map(Result<Element, Failure>.success).catchError { .just(.failure($0 as! Failure)) }
    }
}

