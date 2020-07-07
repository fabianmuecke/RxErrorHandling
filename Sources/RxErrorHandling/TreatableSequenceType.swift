//
//  TreatableConvertibleType.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public protocol TreatableSequenceType: ObservableConvertibleType {
    associatedtype Trait
    associatedtype Failure where Failure: Error

    var treatableSequence: TreatableSequence<Trait, Element, Failure> { get }

    func asObservableResult() -> Observable<Result<Element, Failure>>
}
