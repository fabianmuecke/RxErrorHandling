//
//  ObservableConvertibleType+Treatable.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

extension ObservableConvertibleType {
    public func asTreatable() -> Treatable<Element, Swift.Error> {
        Treatable(raw: asObservable())
    }

    public func asTreatable<Failure>(mapError: @escaping (Error) -> Failure) -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().catchError { .error(mapError($0)) })
    }

    public func asTreatable(onErrorJustReturn element: Element) -> Treatable<Element, Never> {
        Treatable(raw: asObservable().catchErrorJustReturn(element))
    }

    public func asTreatable<Failure>(onErrorTreatWith: @escaping (Error) -> Treatable<Element, Failure>)
        -> Treatable<Element, Failure>
    {
        Treatable(raw: asObservable().catchError { error in
            onErrorTreatWith(error).asObservable()
        })
    }

    /// Make sure your source Observable does not emit any errors except `Failure`. Otherwise using this function is unsafe.
    func asTreatableFromResult<Success, Failure>() -> Treatable<Success, Failure>
        where Element == Swift.Result<Success, Failure>
    {
        Treatable(raw: asObservable().flatMap { (element: Result<Success, Failure>) -> Observable<Success> in
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
