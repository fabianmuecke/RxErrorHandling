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
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().catchError { error in
            onErrorTreatWith(error).asObservable()
        })
    }

    /// Make sure your source Observable already catches all errors and returns Result.failure instead. Otherwise using this function is unsafe.
    public func asTreatableFromResult<Success, Failure>() -> Treatable<Success, Failure>
        where Element == Swift.Result<Success, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Result<Success, Failure>) -> Observable<Success> in
            switch element {
            case let .success(element):
                return .just(element)
            case let .failure(error):
                return .error(error)
            }
        }.catchError { error in
            #if DEBUG
                fatalError("An observable which should never fail produced an error: \(error)")
            #else
                print("An observable which should never fail produced an error: \(error)")
            #endif
        })
    }
}

enum MyError: Swift.Error {}
let obs: Observable<Result<Void, MyError>> = .empty()
let astreatable = obs.asTreatableFromResult()
