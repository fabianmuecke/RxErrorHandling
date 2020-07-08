//
//  TreatableCompletable.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension CompletableTrait: PrimitiveTreatableTrait {}

public typealias TreatableCompletable<Failure: Swift.Error> = TreatableSequence<CompletableTrait,
                                                                                Swift.Never,
                                                                                Failure>
public enum TreatableCompletableEvent<Failure: Swift.Error> {
    case completed
    case failure(Failure)
}

extension TreatableSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    public typealias CompletableObserver = (TreatableCompletableEvent<Failure>) -> Void

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(subscribe: @escaping (@escaping CompletableObserver) -> Disposable)
        -> TreatableCompletable<Failure> {
        let source = Observable<Element>.create { observer in
            subscribe { event in
                switch event {
                case let .failure(error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }

        return TreatableCompletable(raw: source)
    }

    /**
     Subscribes `observer` to receive events for this sequence.

     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    public func subscribe(_ observer: @escaping (TreatableCompletableEvent<Failure>) -> Void) -> Disposable {
        treatableSequence.asCompletable().subscribe { event in
            switch event {
            case let .error(error):
                observer(.failure(error as! Failure))
            case .completed:
                observer(.completed)
            }
        }
    }

    /**
     Subscribes a completion handler and an error handler for this sequence.

     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribe(onCompleted: @escaping (Failure?) -> Void) -> Disposable {
        treatableSequence
            .asCompletable()
            .subscribe(onCompleted: { onCompleted(nil) },
                       onError: {
                           /* swiftformat:disable all */ onCompleted(($0 as! Failure)) /* swiftformat:enable all*/
                       })
    }
}

extension TreatableSequenceType where Trait == CompletableTrait, Element == Swift.Never, Failure == Swift.Never {
    /**
     Subscribes a completion handler and an error handler for this sequence.

     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribe(onCompleted: @escaping () -> Void) -> Disposable {
        treatableSequence.asCompletable().subscribe(onCompleted: onCompleted)
    }
}

extension TreatableSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func failure(_ error: Failure) -> TreatableCompletable<Failure> {
        .init(raw: Completable.error(error))
    }

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> TreatableCompletable<Failure> {
        .init(raw: Completable.never())
    }

    /**
     Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence with no elements.
     */
    public static func empty() -> TreatableCompletable<Failure> {
        .init(raw: Completable.empty())
    }
}

extension TreatableSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onFailure: Action to invoke upon errored termination of the observable sequence.
     - parameter afterFailure: Action to invoke after errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter afterCompleted: Action to invoke after graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(onFailure: ((Failure) -> Void)? = nil,
                     afterFailure: ((Failure) -> Void)? = nil,
                     onCompleted: (() -> Void)? = nil,
                     afterCompleted: (() -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: treatableSequence.asCompletable().do(
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
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func concat(_ second: TreatableCompletable<Failure>) -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: Completable.concat(treatableSequence.asCompletable(), second.asCompletable()))
    }

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Sequence: Swift.Sequence>(_ sequence: Sequence) -> TreatableCompletable<Failure>
        where Sequence.Element == TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.concat(sequence.lazy.map { $0.asObservable() }))
    }

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Collection: Swift.Collection>(_ collection: Collection) -> TreatableCompletable<Failure>
        where Collection.Element == TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.concat(collection.map { $0.asObservable() }))
    }

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat(_ sources: Completable ...) -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.concat(sources.map { $0.asObservable() }))
    }

    /**
     Merges the completion of all Completables from a collection into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Collection of Completables to merge.
     - returns: A Completable that merges the completion of all Completables.
     */
    public static func zip<Collection: Swift.Collection>(_ sources: Collection) -> TreatableCompletable<Failure>
        where Collection.Element == TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.merge(sources.map { $0.asObservable() }))
    }

    /**
     Merges the completion of all Completables from an array into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Array of observable sequences to merge.
     - returns: A Completable that merges the completion of all Completables.
     */
    public static func zip(_ sources: [TreatableCompletable<Failure>]) -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.merge(sources.map { $0.asObservable() }))
    }

    /**
     Merges the completion of all Completables into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func zip(_ sources: TreatableCompletable<Failure>...) -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: Observable.merge(sources.map { $0.asObservable() }))
    }
}
