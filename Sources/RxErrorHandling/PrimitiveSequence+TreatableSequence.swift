//
//  PrimitiveSequence+TreatableSequence.swift
//
//
//  Created by Fabian Mücke on 30.07.20.
//

import Foundation
import RxSwift

extension PrimitiveSequence {
    public func asTreatableSequence() -> TreatableSequence<Trait, Element, Swift.Error> {
        TreatableSequence(raw: asObservable())
    }

    public func asTreatableSequence<Failure>(mapError: @escaping (Error) -> Failure)
        -> TreatableSequence<Trait, Element, Failure>
    {
        TreatableSequence(raw: asObservable().catchError { .error(mapError($0)) })
    }

    public func asTreatableSequence(onErrorJustReturn element: Element) -> TreatableSequence<Trait, Element, Never> {
        TreatableSequence(raw: asObservable().catchErrorJustReturn(element))
    }

    public func asTreatableSequence<Failure>(onErrorTreatWith: @escaping (Error) -> TreatableSequence<Trait, Element, Failure>)
        -> TreatableSequence<Trait, Element, Failure>
    {
        TreatableSequence(raw: asObservable().catchError { error in
            onErrorTreatWith(error).asObservable()
        })
    }

    /// Make sure your source Observable already catches all errors and returns Result.failure instead. Otherwise using this function is unsafe.
    func asTreatableSequenceFromResult<Success, Failure>() -> TreatableSequence<Trait, Success, Failure>
        where Element == Swift.Result<Success, Failure>
    {
        TreatableSequence(raw: asObservable().flatMap { (element: Result<Success, Failure>) -> Observable<Success> in
            switch element {
            case let .success(element):
                return .just(element)
            case let .failure(error):
                return .error(error)
            }
        }
        .do(onError: { error in
            if error as? Failure == nil {
                rxFatalErrorInDebug(
                    "An observable which should only produce \(Failure.self) errors produced error: \(error)"
                )
            }
        }))
    }
}
