//
//  TreatableConvertibleType.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public protocol TreatableConvertibleType: ObservableConvertibleType {
    associatedtype Failure where Failure: Error

    func asTreatable() -> Treatable<Element, Failure>
    func asObservableResult() -> Observable<Result<Element, Failure>>
}

// MARK: map

extension TreatableConvertibleType {
    /**
     Projects each element of an observable sequence into a new form.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func map<NewElement>(_ transform: @escaping (Element) -> NewElement) -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().map(transform))
    }

    /**
     Projects each element of an observable sequence into a new form.

     - parameter transform: A transform function to apply to each source element.
     - parameter mapError: A transform function to apply to occurring errors.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func map<NewElement>(_ transform: @escaping (Element) throws -> NewElement,
                                mapError: @escaping (Error) -> Failure) -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Element) -> Observable<NewElement> in
            do {
                return .just(try transform(element))
            } catch {
                return .error(mapError(error))
            }
        })
    }

    /**
     Projects each element of an observable sequence into a new form. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapResult<NewElement>(_ transform: @escaping (Element) -> Result<NewElement, Failure>)
        -> Treatable<NewElement, Failure> {
        asObservable().map(transform).asTreatable()
    }

    /**
     Projects each element of an observable sequence into a new form. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapResult<NewElement, NewFailure>(
        _ transform: @escaping (Result<Element, Failure>) -> Result<NewElement, NewFailure>)
        -> Treatable<NewElement, NewFailure> {
        asObservableResult().map(transform).asTreatable()
    }

    /**
     Projects each error of an observable sequence into a new form.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapError<NewFailure>(_ transform: @escaping (Failure) -> NewFailure) -> Treatable<Element, NewFailure> {
        Treatable(raw: asObservable().catchError { .error(transform($0 as! Failure)) })
    }
}

// MARK: compactMap

extension TreatableConvertibleType {
    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<NewElement>(_ transform: @escaping (Element) -> NewElement?)
        -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().compactMap(transform))
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMapResult<NewElement>(_ transform: @escaping (Element) -> Result<NewElement, Failure>?)
        -> Treatable<NewElement, Failure> {
        asObservable().compactMap(transform).asTreatable()
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - parameter mapError: A transform function to apply to occurring errors and which returns a failure or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<NewElement>(_ transform: @escaping (Element) throws -> NewElement?,
                                       mapError: @escaping (Error) -> Failure?) -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().compactMap { (element: Element) -> NewElement? in
            do {
                if let result = try transform(element) {
                    return result
                }
                return nil
            } catch {
                if let failure = mapError(error) {
                    throw failure
                }
                return nil
            }
        })
    }
}

// MARK: filter

extension TreatableConvertibleType {
    /**
     Filters the elements of an observable sequence based on a predicate.

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (Element) -> Bool) -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().filter(predicate))
    }

    /**
     Filters the elements of an observable sequence based on a predicate.

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filterResult(_ predicate: @escaping (Result<Element, Failure>) -> Bool) -> Treatable<Element, Failure> {
        asObservableResult().filter(predicate).asTreatable()
    }

    /**
     Filters the elements of an observable sequence based on a predicate.

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filterError(_ predicate: @escaping (Failure) -> Bool) -> Treatable<Element, Failure> {
        asObservableResult().filter { element in
            switch element {
            case .success:
                return true
            case let .failure(error):
                return predicate(error)
            }
        }.asTreatable()
    }
}

// MARK: Failure type

extension TreatableConvertibleType where Failure == Never {
    // TODO: Have a custom TreatableConvertibleType for non-fallible like apple does, so setFailureType can be called again later?
    public func setFailureType<NewFailure>(to failureType: NewFailure.Type) -> Treatable<Element, NewFailure> {
        Treatable(raw: asObservable())
    }
}

// MARK: switchLatest

extension TreatableConvertibleType where Element: TreatableConvertibleType {
    /**
     Transforms an observable sequence of observable sequences into an observable sequence
     producing values only from the most recent observable sequence.

     Each time a new inner observable sequence is received, unsubscribe from the
     previous inner observable sequence.

     - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func switchLatest() -> Treatable<Element.Element, Element.Failure> {
        Treatable(raw: asObservable().switchLatest())
    }
}

// MARK: flatMapLatest

extension TreatableConvertibleType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - parameter transform: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func flatMapLatest<NewElement>(_ transform: @escaping (Element) -> Treatable<NewElement, Failure>)
        -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMapLatest(transform))
    }
}

// MARK: flatMapFirst

extension TreatableConvertibleType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - parameter transform: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    public func flatMapFirst<NewElement>(_ transform: @escaping (Element) -> Treatable<NewElement, Failure>)
        -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMapFirst(transform))
    }
}

// MARK: do

extension TreatableConvertibleType {
    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter afterNext: Action to invoke for each element after the observable has passed an onNext event along to its downstream.
     - parameter onCompleted: Action to invoke upon termination of the observable sequence.
     - parameter afterCompleted: Action to invoke after termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(
        onNext: ((Element) -> Void)? = nil,
        afterNext: ((Element) -> Void)? = nil,
        onCompleted: ((Treatable<Element, Failure>.Completion) -> Void)? = nil,
        afterCompleted: ((Treatable<Element, Failure>.Completion) -> Void)? = nil,
        onSubscribe: (() -> Void)? = nil,
        onSubscribed: (() -> Void)? = nil,
        onDispose: (() -> Void)? = nil
    )
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable()
            .do(
                onNext: onNext,
                afterNext: afterNext,
                onError: onCompleted.map { call in { failure in call(.failure(failure as! Failure)) } },
                afterError: afterCompleted.map { call in { failure in call(.failure(failure as! Failure)) } },
                onCompleted: onCompleted.map { call in { call(.finished) } },
                afterCompleted: afterCompleted.map { call in { call(.finished) } },
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose
            ))
    }
}

// MARK: debug

extension TreatableConvertibleType {
    /**
     Prints received events for all observers on standard output.

     - parameter identifier: Identifier that is printed together with event description to standard output.
     - returns: An observable sequence whose events are printed to standard output.
     */
    public func debug(
        _ identifier: String? = nil,
        trimOutput: Bool = false,
        file: String = #file,
        line: UInt = #line,
        function: String = #function
    ) -> Treatable<Element, Failure> {
        Treatable(raw: asObservable()
            .debug(identifier, trimOutput: trimOutput, file: file, line: line, function: function))
    }
}

// MARK: distinctUntilChanged

extension TreatableConvertibleType where Element: Equatable {
    /**
     Returns an observable sequence that contains only distinct contiguous elements according to equality operator.

     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    public func distinctUntilChanged() -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().distinctUntilChanged({ $0 }, comparer: { ($0 == $1) }))
    }
}

extension TreatableConvertibleType {
    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.

     - parameter keySelector: A function to compute the comparison key for each element.
     - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
     */
    public func distinctUntilChanged<Key: Equatable>(_ keySelector: @escaping (Element) -> Key)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().distinctUntilChanged(keySelector, comparer: { $0 == $1 }))
    }

    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.

     - parameter comparer: Equality comparer for computed key values.
     - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
     */
    public func distinctUntilChanged(_ comparer: @escaping (Element, Element) -> Bool)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().distinctUntilChanged({ $0 }, comparer: comparer))
    }

    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.

     - parameter keySelector: A function to compute the comparison key for each element.
     - parameter comparer: Equality comparer for computed key values.
     - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
     */
    public func distinctUntilChanged<K>(_ keySelector: @escaping (Element) -> K,
                                        comparer: @escaping (K, K) -> Bool)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().distinctUntilChanged(keySelector, comparer: comparer))
    }
}

// MARK: flatMap

extension TreatableConvertibleType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - parameter transform: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<NewElement>(_ transform: @escaping (Element) -> Treatable<NewElement, Failure>)
        -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMap(transform))
    }
}

// MARK: merge

extension TreatableConvertibleType {
    /**
     Merges elements from all observable sequences from collection into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge<Collection: Swift.Collection>(_ sources: Collection) -> Treatable<Element, Failure> where
        Collection.Element: TreatableConvertibleType,
        Collection.Element.Element == Element,
        Collection.Element.Failure == Failure {
        Treatable<Element, Failure>(raw: Observable.merge(sources.map { $0.asObservable() }))
    }

    /**
     Merges elements from all observable sequences from array into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Array of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: [Treatable<Element, Failure>]) -> Treatable<Element, Failure> {
        Treatable<Element, Failure>(raw: Observable.merge(sources.map { $0.asObservable() }))
    }

    /**
     Merges elements from all observable sequences into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: Treatable<Element, Failure>...) -> Treatable<Element, Failure> {
        Treatable<Element, Failure>(raw: Observable.merge(sources.map { $0.asObservable() }))
    }
}

extension TreatableConvertibleType where Element: TreatableConvertibleType {
    /**
     Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.

     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public func merge() -> Treatable<Element.Element, Element.Failure> {
        Treatable(raw: asObservable().merge())
    }

    /**
     Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.

     - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
     - returns: The observable sequence that merges the elements of the inner sequences.
     */
    public func merge(maxConcurrent: Int) -> Treatable<Element.Element, Element.Failure> {
        Treatable(raw: asObservable().merge(maxConcurrent: maxConcurrent))
    }
}

// MARK: throttle

extension TreatableConvertibleType {
    /**
     Returns an Observable that emits the first and the latest item emitted by the source Observable during sequential time windows of a specified duration.

     This operator makes sure that no two elements are emitted in less then dueTime.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter latest: Should latest element received in a dueTime wide time window since last element emission be emitted.
     - returns: The throttled sequence.
     */
    public func throttle(_ dueTime: RxTimeInterval, latest: Bool = true,
                         scheduler: SchedulerType) -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().throttle(dueTime, latest: latest, scheduler: scheduler))
    }

    /**
     Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

     - parameter dueTime: Throttling duration for each element.
     - returns: The throttled sequence.
     */
    public func debounce(_ dueTime: RxTimeInterval, scheduler: SchedulerType) -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().debounce(dueTime, scheduler: scheduler))
    }
}

// MARK: scan

extension TreatableConvertibleType {
    /**
     Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

     For aggregation behavior with no intermediate results, see `reduce`.

     - parameter seed: The initial accumulator value.
     - parameter accumulator: An accumulator function to be invoked on each element.
     - returns: An observable sequence containing the accumulated values.
     */
    public func scan<Accumulated>(_ seed: Accumulated, accumulator: @escaping (Accumulated, Element) -> Accumulated)
        -> Treatable<Accumulated, Failure> {
        Treatable(raw: asObservable().scan(seed, accumulator: accumulator))
    }
}

// MARK: concat

extension TreatableConvertibleType {
    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Sequence: Swift.Sequence>(_ sequence: Sequence) -> Treatable<Element, Failure>
        where Sequence.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.concat(sequence.lazy.map { $0.asObservable() }))
    }

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Collection: Swift.Collection>(_ collection: Collection) -> Treatable<Element, Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.concat(collection.map { $0.asObservable() }))
    }
}

extension TreatableConvertibleType {
    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func concat<Source: TreatableConvertibleType>(_ second: Source) -> Treatable<Element, Failure>
        where Source.Element == Element, Source.Failure == Failure {
        Treatable(raw: Observable.concat([asObservable(), second.asObservable()]))
    }
}

// MARK: zip

extension TreatableConvertibleType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - parameter mapError: Function to map errors to the Treatables Failure type.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arityWithError = 8
    public static func zip<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) throws -> Result,
        mapError: @escaping (Error) -> Failure
    ) -> Treatable<Result, Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.zip(
            collection.map { $0.asObservable() },
            resultSelector: { elements in
                do {
                    return try resultSelector(elements)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arity = 8
    public static func zip<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) -> Result
    ) -> Treatable<Result, Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.zip(
            collection.map { $0.asObservable() },
            resultSelector: resultSelector
        ))
    }

    /**
     Merges the specified observable sequences into one observable sequence all of the observable sequences have produced an element at a corresponding index.

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func zip<Collection: Swift.Collection>(_ collection: Collection) -> Treatable<[Element], Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.zip(collection.map { $0.asObservable() }))
    }
}

// MARK: combineLatest

extension TreatableConvertibleType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

     - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
     - parameter mapError: Function to map errors to Treatable Failure type.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arityWithError = 8
    public static func combineLatest<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) throws -> Result,
        mapError: @escaping (Error) -> Failure
    ) -> Treatable<Result, Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw:
            Observable.combineLatest(
                collection.map { $0.asObservable() },
                resultSelector: { elements in
                    do {
                        return try resultSelector(elements)
                    } catch {
                        throw mapError(error)
                    }
                }
            )
        )
    }

    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

     - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    // sourcery: arity = 8
    public static func combineLatest<Collection: Swift.Collection, Result>(
        _ collection: Collection,
        resultSelector: @escaping ([Element]) -> Result
    ) -> Treatable<Result, Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw:
            Observable.combineLatest(
                collection.map { $0.asObservable() },
                resultSelector: resultSelector
            )
        )
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever any of the observable sequences produces an element.

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func combineLatest<Collection: Swift.Collection>(_ collection: Collection)
        -> Treatable<[Element], Failure>
        where Collection.Element == Treatable<Element, Failure> {
        Treatable(raw: Observable.combineLatest(collection.map { $0.asObservable() }))
    }
}

// MARK: withLatestFrom

extension TreatableConvertibleType {
    /**
     Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.

     - parameter second: Second observable source.
     - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    public func withLatestFrom<SecondO: TreatableConvertibleType, ResultType>(
        _ second: SecondO,
        resultSelector: @escaping (Element, SecondO.Element) -> ResultType
    ) -> Treatable<ResultType, Failure> where SecondO.Failure == Failure {
        Treatable(raw: asObservable().withLatestFrom(second, resultSelector: resultSelector))
    }

    /**
     Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emits an element.

     - parameter second: Second observable source.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    public func withLatestFrom<SecondO: TreatableConvertibleType>(_ second: SecondO)
        -> Treatable<SecondO.Element, Failure> where SecondO.Failure == Failure {
        Treatable(raw: asObservable().withLatestFrom(second))
    }
}

// MARK: skip

extension TreatableConvertibleType {
    /**
     Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter count: The number of elements to skip before returning the remaining elements.
     - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
     */
    public func skip(_ count: Int)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().skip(count))
    }
}

// MARK: startWith

extension TreatableConvertibleType {
    /**
     Prepends a value to an observable sequence.

     - seealso: [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)

     - parameter element: Element to prepend to the specified sequence.
     - returns: The source sequence prepended with the specified values.
     */
    public func startWith(_ element: Element)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().startWith(element))
    }
}

// MARK: delay

extension TreatableConvertibleType {
    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    public func delay(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().delay(dueTime, scheduler: scheduler))
    }
}

// MARK: share

extension TreatableConvertibleType {
    /**
     Returns an observable sequence that **shares a single subscription to the underlying sequence**, and immediately upon subscription replays  elements in buffer.

     This operator is equivalent to:
     * `.whileConnected`
     ```
     // Each connection will have it's own subject instance to store replay events.
     // Connections will be isolated from each another.
     source.multicast(makeSubject: { Replay.create(bufferSize: replay) }).refCount()
     ```
     * `.forever`
     ```
     // One subject will store replay events for all connections to source.
     // Connections won't be isolated from each another.
     source.multicast(Replay.create(bufferSize: replay)).refCount()
     ```

     It uses optimized versions of the operators for most common operations.

     - parameter replay: Maximum element count of the replay buffer.
     - parameter scope: Lifetime scope of sharing subject. For more information see `SubjectLifetimeScope` enum.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func share(replay: Int = 0, scope: SubjectLifetimeScope = .whileConnected)
        -> Treatable<Element, Failure> {
        Treatable(raw: asObservable().share(replay: replay, scope: scope))
    }
}
