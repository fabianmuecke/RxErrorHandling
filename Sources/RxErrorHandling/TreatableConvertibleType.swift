//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public protocol TreatableConvertibleType: ObservableConvertibleType {
    associatedtype Failure where Failure: Error
    associatedtype Success where Element == Success

    func asObservableResult() -> Observable<Result<Success, Failure>>
}

extension TreatableConvertibleType {
    public func map<NewSuccess>(_ transform: @escaping (Success) -> NewSuccess) -> Treatable<NewSuccess, Failure> {
        Treatable(raw: asObservable().map(transform))
    }

    public func map<NewSuccess>(_ transform: @escaping (Success) throws -> NewSuccess,
                                catchError: @escaping (Error) -> Failure) -> Treatable<NewSuccess, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Success) -> Observable<NewSuccess> in
            do {
                return .just(try transform(element))
            } catch {
                return .error(catchError(error))
            }
        })
    }

    public func map<NewSuccess>(_ transform: @escaping (Success) -> Result<NewSuccess, Failure>)
        -> Treatable<NewSuccess, Failure> {
        asObservable().map(transform).asTreatable()
    }

    public func map<NewSuccess, NewFailure>(
        _ transform: @escaping (Result<Success, Failure>) -> Result<NewSuccess, NewFailure>)
        -> Treatable<NewSuccess, NewFailure> {
        asObservableResult().map(transform).asTreatable()
    }

    public func mapError<NewFailure>(_ transform: @escaping (Failure) -> NewFailure) -> Treatable<Success, NewFailure> {
        Treatable(raw: asObservable().catchError { .error(transform($0 as! Failure)) })
    }
}

extension TreatableConvertibleType where Failure == Never {
    // TODO: Have a custom TreatableConvertibleType for non-fallible like apple does, so setFailureType can be called again later?
    public func setFailureType<NewFailure>(to failureType: NewFailure.Type) -> Treatable<Success, NewFailure> {
        Treatable(raw: asObservable())
    }
}

extension TreatableConvertibleType {
    public static func merge<Collection: Swift.Collection>(_ sources: Collection)
        -> Treatable<Success, Failure> where
        Collection.Element: TreatableConvertibleType,
        Collection.Element.Success == Success,
        Collection.Element.Failure == Failure {
        let source = Observable.merge(sources.map { $0.asObservable() })
        return Treatable<Success, Failure>(raw: source)
    }

    public static func merge(_ sources: [Treatable<Success, Failure>])
        -> Treatable<Success, Failure> {
        let source = Observable.merge(sources.map { $0.asObservable() })
        return Treatable<Success, Failure>(raw: source)
    }

    public static func merge(_ sources: Treatable<Success, Failure>...)
        -> Treatable<Success, Failure> {
        let source = Observable.merge(sources.map { $0.asObservable() })
        return Treatable<Success, Failure>(raw: source)
    }
}

// extension TreatableConvertibleType where Element: TreatableConvertibleType {
//    func merge() -> Treatable<Self.Success, Self.Failure> {
//        asObservable().map { $0.asTreatable() }.merge()
//////        let source = self.asObservable()
//////            .map { $0.asSharedSequence() }
//////            .merge()
//////        return SharedSequence<Element.SharingStrategy, Element.Element>(source)
//    }
// }
