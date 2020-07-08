//
//  TreatableSingle+Operators.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension TreatableSequenceType where Trait == SingleTrait {
    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter afterSuccess: Action to invoke for each element after the observable has passed an onNext event along to its downstream.
     - parameter onFailure: Action to invoke upon errored termination of the observable sequence.
     - parameter afterFailure: Action to invoke after errored termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(onSuccess: ((Element) -> Void)? = nil,
                     afterSuccess: ((Element) -> Void)? = nil,
                     onFailure: ((Failure) -> Void)? = nil,
                     afterFailure: ((Failure) -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> TreatableSingle<Element, Failure> {
        TreatableSingle(raw: treatableSequence.asSingle().do(
            onSuccess: onSuccess,
            afterSuccess: afterSuccess,
            onError: onFailure.map { call in { call($0 as! Failure) } },
            afterError: afterFailure.map { call in { call($0 as! Failure) } },
            onSubscribe: onSubscribe,
            onSubscribed: onSubscribed,
            onDispose: onDispose
        )
        )
    }

    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (Element) -> Bool)
        -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: treatableSequence.source.filter(predicate))
    }

    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<NewElement>(_ transform: @escaping (Element) -> NewElement)
        -> TreatableSingle<NewElement, Failure> {
        TreatableSingle(raw: treatableSequence.source.map(transform))
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<NewElement>(_ transform: @escaping (Element) -> NewElement?)
        -> TreatableMaybe<NewElement, Failure> {
        TreatableMaybe(raw: treatableSequence.source.compactMap(transform))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<NewElement>(_ selector: @escaping (Element) -> TreatableSingle<NewElement, Failure>)
        -> TreatableSingle<NewElement, Failure> {
        TreatableSingle(raw: treatableSequence.source.flatMap(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMapMaybe<NewElement>(_ selector: @escaping (Element) -> TreatableMaybe<NewElement, Failure>)
        -> TreatableMaybe<NewElement, Failure> {
        TreatableMaybe(raw: treatableSequence.source.flatMap(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMapCompletable(_ selector: @escaping (Element) -> TreatableCompletable<Failure>)
        -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: treatableSequence.source.flatMap(selector))
    }

    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arity = 8, trait = "SingleTrait"
    public static func zip<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) -> Result
    ) -> TreatableSingle<Result,
                         Failure>
        where Collection.Element == TreatableSequence<Trait, Element, Failure> {
        guard !collection.isEmpty else {
            return TreatableSingle.deferred {
                TreatableSingle(raw: Single.just(resultSelector([])))
            }
        }

        let raw = Observable.zip(collection.map { $0.asObservable() }, resultSelector: resultSelector)
        return TreatableSingle(raw: raw)
    }

    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arityWithError = 8, trait = "SingleTrait"
    public static func zip<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) throws -> Result,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSingle<Result,
                         Failure>
        where Collection.Element == TreatableSequence<Trait, Element, Failure> {
        let selectResult: ([Element]) throws -> Result = { elements in
            do {
                return try resultSelector(elements)
            } catch {
                throw mapError(error)
            }
        }

        guard !collection.isEmpty else {
            return TreatableSingle.deferred {
                TreatableSingle(raw: Single.just(try selectResult([])))
            }
        }

        let raw = Observable.zip(collection.map { $0.asObservable() }, resultSelector: selectResult)
        return TreatableSingle(raw: raw)
    }

    /**
     Merges the specified observable sequences into one observable sequence all of the observable sequences have produced an element at a corresponding index.

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func zip<Collection: Swift.Collection>(_ collection: Collection)
        -> TreatableSingle<[Element], Failure> where Collection.Element == TreatableSingle<Element, Failure> {
        guard !collection.isEmpty else {
            return TreatableSingle(raw: Single.just([]))
        }
        return TreatableSingle(raw: Observable.zip(collection.map { $0.asObservable() }))
    }

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    public func catchErrorJustReturn(_ element: Element)
        -> TreatableSingle<Element, Never> {
        return TreatableSingle(raw: treatableSequence.source.catchErrorJustReturn(element))
    }

    /// Converts `self` to `Maybe` trait.
    ///
    /// - returns: Maybe trait that represents `self`.
    public func asMaybe() -> TreatableMaybe<Element, Failure> {
        return TreatableMaybe(raw: treatableSequence.source)
    }

    /// Converts `self` to `Completable` trait.
    ///
    /// - returns: Completable trait that represents `self`.
    public func asCompletable() -> TreatableCompletable<Failure> {
        return TreatableCompletable(raw: treatableSequence.source.ignoreElements())
    }
}
