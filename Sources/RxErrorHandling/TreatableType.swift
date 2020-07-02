//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

protocol TreatableType: ObservableConvertibleType {
    associatedtype Failure where Failure: Error

    func asSafeObservable() -> Observable<Result<Element, Failure>>
}

extension TreatableType {
    public func map<NewElement>(_ transform: @escaping (Element) -> NewElement) -> Treatable<NewElement, Failure> {
        Treatable(raw: asSafeObservable().map { $0.map(transform) })
    }

    public func map<NewFailure>(_ transform: @escaping (Element) throws -> NewFailure,
                                catchError: @escaping (Error) -> Failure) -> Treatable<NewFailure, Failure> {
        Treatable(raw: asSafeObservable().map {
            switch $0 {
            case let .success(element):
                do {
                    return .success(try transform(element))
                } catch {
                    return .failure(catchError(error))
                }
            case let .failure(error):
                return .failure(error)
            }
        })
    }

    public func map<NewElement>(_ transform: @escaping (Element) -> Result<NewElement, Failure>)
        -> Treatable<NewElement, Failure> {
        Treatable(raw: asSafeObservable().map { $0.flatMap(transform) })
    }

    public func map<NewElement, NewFailure>(
        _ transform: @escaping (Result<Element, Failure>) -> Result<NewElement, NewFailure>)
        -> Treatable<NewElement, NewFailure> {
        Treatable(raw: asSafeObservable().map { transform($0) })
    }

    public func mapError<Result>(_ transform: @escaping (Failure) -> Result) -> Treatable<Element, Result> {
        Treatable(raw: asSafeObservable().map {
            $0.mapError(transform)
        })
    }
}
