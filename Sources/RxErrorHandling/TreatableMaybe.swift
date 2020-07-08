//
//  TreatableMaybe.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension MaybeTrait: PrimitiveTreatableTrait {}

public typealias TreatableMaybe<Element, Failure: Swift.Error> = TreatableSequence<MaybeTrait,
                                                                                   Element,
                                                                                   Failure>

public enum TreatableMaybeEvent<Element, Failure> {
    case success(Element?)

    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case failure(Failure)
}

extension TreatableSequenceType where Trait == MaybeTrait {
    public typealias MaybeObserver = (TreatableMaybeEvent<Element, Failure>) -> Void

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(subscribe: @escaping (@escaping MaybeObserver) -> Disposable)
        -> TreatableSequence<Trait, Element, Failure> {
        let source = Observable<Element>.create { observer in
            subscribe { event in
                switch event {
                case .success(.none):
                    observer.on(.completed)
                case let .success(.some(element)):
                    observer.on(.next(element))
                    observer.on(.completed)
                case let .failure(error):
                    observer.on(.error(error))
                }
            }
        }

        return TreatableSequence(raw: source)
    }

    /**
     Subscribes `observer` to receive events for this sequence.

     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    public func subscribe(_ observer: @escaping MaybeObserver) -> Disposable {
        treatableSequence
            .asMaybe()
            .subscribe(onSuccess: { observer(.success($0)) },
                       onError: { observer(.failure($0 as! Failure)) },
                       onCompleted: { observer(.success(nil)) })
    }
}

extension TreatableSequenceType where Trait == MaybeTrait {
    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element) -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: Observable.just(element))
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: Observable.just(element, scheduler: scheduler))
    }

    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func error(_ error: Swift.Error) -> TreatableMaybe<Element, Failure> {
        TreatableSequence(raw: Observable.error(error))
    }

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> TreatableMaybe<Element, Failure> {
        TreatableSequence(raw: Observable.never())
    }

    /**
     Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence with no elements.
     */
    public static func empty() -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: Observable.empty())
    }
}

extension TreatableSequenceType where Trait == MaybeTrait {
    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter afterNext: Action to invoke for each element after the observable has passed an onNext event along to its downstream.
     - parameter onFailure: Action to invoke upon errored termination of the observable sequence.
     - parameter afterFailure: Action to invoke after errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter afterCompleted: Action to invoke after graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(onNext: ((Element) -> Void)? = nil,
                     afterNext: ((Element) -> Void)? = nil,
                     onFailure: ((Failure) -> Void)? = nil,
                     afterFailure: ((Failure) -> Void)? = nil,
                     onCompleted: (() -> Void)? = nil,
                     afterCompleted: (() -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> TreatableMaybe<Element, Failure> {
        return TreatableMaybe(raw: treatableSequence.source.do(
            onNext: onNext,
            afterNext: afterNext,
            onError: onFailure.map { call in { call($0 as! Failure) } },
            afterError: afterFailure.map { call in { call($0 as! Failure) } },
            onCompleted: onCompleted,
            afterCompleted: afterCompleted,
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
    public func filter(_ predicate: @escaping (Element) throws -> Bool)
        -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: treatableSequence.source.filter(predicate))
    }

    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<NewElement>(_ transform: @escaping (Element) throws -> NewElement)
        -> TreatableMaybe<NewElement, Failure> {
        TreatableMaybe(raw: treatableSequence.source.map(transform))
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<NewElement>(_ transform: @escaping (Element) throws -> NewElement?)
        -> TreatableMaybe<NewElement, Failure> {
        TreatableMaybe(raw: treatableSequence.source.compactMap(transform))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<NewElement>(_ selector: @escaping (Element) throws -> TreatableMaybe<NewElement, Failure>)
        -> TreatableMaybe<NewElement, Failure> {
        TreatableMaybe(raw: treatableSequence.source.flatMap(selector))
    }

    /**
     Emits elements from the source observable sequence, or a default element if the source observable sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter default: Default element to be sent if the source does not emit any elements
     - returns: An observable sequence which emits default element end completes in case the original sequence is empty
     */
    public func ifEmpty(default: Element) -> TreatableSingle<Element, Failure> {
        TreatableSingle(raw: treatableSequence.source.ifEmpty(default: `default`))
    }

    /**
     Returns the elements of the specified sequence or `switchTo` sequence if the sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter switchTo: Observable sequence being returned when source sequence is empty.
     - returns: Observable sequence that contains elements from switchTo sequence if source is empty, otherwise returns source sequence elements.
     */
    public func ifEmpty(switchTo other: TreatableMaybe<Element, Failure>) -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: treatableSequence.source.ifEmpty(switchTo: other.treatableSequence.source))
    }

    /**
     Returns the elements of the specified sequence or `switchTo` sequence if the sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter switchTo: Observable sequence being returned when source sequence is empty.
     - returns: Observable sequence that contains elements from switchTo sequence if source is empty, otherwise returns source sequence elements.
     */
    public func ifEmpty(switchTo other: TreatableSingle<Element, Failure>) -> TreatableSingle<Element, Failure> {
        TreatableSingle(raw: treatableSequence.source.ifEmpty(switchTo: other.treatableSequence.source))
    }

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    public func catchErrorJustReturn(_ element: Element)
        -> TreatableSequence<Trait, Element, Never> {
        TreatableSequence(raw: treatableSequence.source.catchErrorJustReturn(element))
    }
}
