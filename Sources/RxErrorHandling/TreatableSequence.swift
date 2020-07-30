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

extension TreatableSequence {
    /**
     Projects each element of an observable sequence into a new form. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapResult<NewElement>(_ transform: @escaping (Element) -> Result<NewElement, Failure>)
        -> TreatableSequence<Trait, NewElement, Failure> {
        let treatable = asObservable().map(transform).asTreatableFromResult()
        return TreatableSequence<Trait, NewElement, Failure>(raw: treatable)
    }

    /**
     Projects each element of an observable sequence into a new form. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapResult<NewElement, NewFailure>(
        _ transform: @escaping (Result<Element, Failure>) -> Result<NewElement, NewFailure>)
        -> TreatableSequence<Trait, NewElement, NewFailure> {
        let treatable = asObservableResult().map(transform).asTreatableFromResult()
        return TreatableSequence<Trait, NewElement, NewFailure>(raw: treatable)
    }

    /**
     Projects each error of an observable sequence into a new form.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapError<NewFailure>(_ transform: @escaping (Failure) -> NewFailure)
        -> TreatableSequence<Trait, Element, NewFailure> {
        let treatable = asObservable().catchError { .error(transform($0 as! Failure)) }
        return TreatableSequence<Trait, Element, NewFailure>(raw: treatable)
    }
}
