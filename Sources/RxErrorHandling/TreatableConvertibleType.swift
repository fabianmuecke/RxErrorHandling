//
//  File.swift
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
     - parameter catchError: A transform function to apply to occurring errors.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func map<NewElement>(_ transform: @escaping (Element) throws -> NewElement,
                                catchError: @escaping (Error) -> Failure) -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Element) -> Observable<NewElement> in
            do {
                return .just(try transform(element))
            } catch {
                return .error(catchError(error))
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
     - parameter catchError: A transform function to apply to occurring errors and which returns a failure or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<NewElement>(_ transform: @escaping (Element) throws -> NewElement?,
                                       catchError: @escaping (Error) -> Failure?) -> Treatable<NewElement, Failure> {
        Treatable(raw: asObservable().flatMap { (element: Element) -> Observable<NewElement> in
            do {
                if let result = try transform(element) {
                    return .just(result)
                }
                return .empty()
            } catch {
                if let failure = catchError(error) {
                    return .error(failure)
                }
                return .empty()
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
