//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

extension ObservableConvertibleType {
    public func asTreatable<Failure>(catchError: @escaping (Error) -> Failure) -> Treatable<Element, Failure> {
        Treatable(source: asObservable(), errorTransform: catchError)
    }
}

extension ObservableConvertibleType {
    public func asTreatable<Success, Failure>() -> Treatable<Success, Failure>
        where Element == Swift.Result<Success, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Result<Success, Failure>) -> Observable<Success> in
            switch element {
            case let .success(element):
                return .just(element)
            case let .failure(error):
                return .error(error)
            }
            // TODO: should we really rely on no error occurring in the source, just because the result type is Swift.Result?
        })
    }
}
