//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

protocol TreatableType: ObservableConvertibleType {
    associatedtype Failure where Failure: Error
    associatedtype Success where Element == Result<Success, Failure>
}

extension TreatableType {
    public func map<NewSuccess>(_ transform: @escaping (Success) -> NewSuccess) -> Treatable<NewSuccess, Failure> {
        Treatable(raw: asObservable().map { $0.map(transform) })
    }

    public func map<NewSuccess>(_ transform: @escaping (Success) throws -> NewSuccess,
                                catchError: @escaping (Error) -> Failure) -> Treatable<NewSuccess, Failure> {
        Treatable(raw: asObservable().map {
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

    public func map<NewSuccess>(_ transform: @escaping (Success) -> Result<NewSuccess, Failure>)
        -> Treatable<NewSuccess, Failure> {
        Treatable(raw: asObservable().map { $0.flatMap(transform) })
    }

    public func map<NewSuccess, NewFailure>(
        _ transform: @escaping (Element) -> Result<NewSuccess, NewFailure>)
        -> Treatable<NewSuccess, NewFailure> {
        Treatable(raw: asObservable().map { transform($0) })
    }

    public func mapError<NewFailure>(_ transform: @escaping (Failure) -> NewFailure) -> Treatable<Success, NewFailure> {
        Treatable(raw: asObservable().map {
            $0.mapError(transform)
        })
    }
}
