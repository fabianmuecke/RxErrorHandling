//
//  TreatableSequence.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

public struct TreatableSequence<Trait, Element, Failure: Swift.Error> {
    let source: Observable<Element>

    // UNSAFE: Only use, if you made sure all possible occuring errors are of `Failure` type.
    public init<O: ObservableConvertibleType>(raw: O) where O.Element == Element {
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
     Projects each error of an observable sequence into a new form.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapError<NewFailure>(_ transform: @escaping (Failure) -> NewFailure)
        -> TreatableSequence<Trait, Element, NewFailure> {
        let treatable = asObservable().catchError { .error(transform($0 as! Failure)) }
        return TreatableSequence<Trait, Element, NewFailure>(raw: treatable)
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results. Failure is treated as an error.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMapResult<NewElement>(_ transform: @escaping (Element) -> Result<NewElement, Failure>?)
        -> TreatableSequence<Trait, NewElement, Failure> {
        let treatable = asObservable().compactMap(transform).asTreatableFromResult()
        return TreatableSequence<Trait, NewElement, Failure>(raw: treatable)
    }
}

// MARK: Failure type

extension TreatableSequenceType where Failure == Never {
    // TODO: Have a custom TreatableConvertibleType for non-fallible like apple does, so setFailureType can be called again later?
    public func setFailureType<NewFailure>(to failureType: NewFailure
        .Type) -> TreatableSequence<Trait, Element, NewFailure> {
        TreatableSequence<Trait, Element, NewFailure>(raw: asObservable())
    }
}

extension TreatableSequenceType {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () throws -> TreatableSequence<Trait, Element, Failure>)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: Observable.deferred {
            try observableFactory().asObservable()
        })
    }

    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    public func delay(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.delay(dueTime, scheduler: scheduler))
    }

    /**
     Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the subscription.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: Time-shifted sequence.
     */
    public func delaySubscription(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.delaySubscription(dueTime, scheduler: scheduler))
    }

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    public func observeOn(_ scheduler: ImmediateSchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.observeOn(scheduler))
    }

    /**
     Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
     scheduler.

     This operation is not commonly used.

     This only performs the side-effects of subscription and unsubscription on the specified scheduler.

     In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

     - seealso: [subscribeOn operator on reactivex.io](http://reactivex.io/documentation/operators/subscribeon.html)

     - parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
     - returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
     */
    public func subscribeOn(_ scheduler: ImmediateSchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.subscribeOn(scheduler))
    }

    /**
     If the initial subscription to the observable sequence emits an error event, try repeating it up to the specified number of attempts (inclusive of the initial attempt) or until is succeeds. For example, if you want to retry a sequence once upon failure, you should use retry(2) (once for the initial attempt, and once for the retry).

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to attempt the sequence subscription.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
    public func retry(_ maxAttemptCount: Int)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.retry(maxAttemptCount))
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    public func retryWhen<TriggerObservable: ObservableType,
                          Error: Swift.Error>(_ notificationHandler: @escaping (Observable<Error>) -> TriggerObservable)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.retryWhen(notificationHandler))
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    public func retryWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Swift.Error>)
        -> TriggerObservable)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source.retryWhen(notificationHandler))
    }

    /**
     Prints received events for all observers on standard output.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter identifier: Identifier that is printed together with event description to standard output.
     - parameter trimOutput: Should output be trimmed to max 40 characters.
     - returns: An observable sequence whose events are printed to standard output.
     */
    public func debug(
        _ identifier: String? = nil,
        trimOutput: Bool = false,
        file: String = #file,
        line: UInt = #line,
        function: String = #function
    )
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: treatableSequence.source
            .debug(identifier, trimOutput: trimOutput, file: file, line: line, function: function))
    }

    /**
     Constructs an observable sequence that depends on a resource object, whose lifetime is tied to the resulting observable sequence's lifetime.

     - seealso: [using operator on reactivex.io](http://reactivex.io/documentation/operators/using.html)

     - parameter resourceFactory: Factory function to obtain a resource object.
     - parameter treatableSequenceFactory: Factory function to obtain an observable sequence that depends on the obtained resource.
     - returns: An observable sequence whose lifetime controls the lifetime of the dependent resource object.
     */
    public static func using<Resource: Disposable>(
        _ resourceFactory: @escaping () throws -> Resource,
        treatableSequenceFactory: @escaping (Resource) throws -> TreatableSequence<Trait, Element, Failure>
    )
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence(raw: Observable
            .using(resourceFactory, observableFactory: { (resource: Resource) throws -> Observable<Element> in
                try treatableSequenceFactory(resource).asObservable()
            }))
    }

    /**
     Applies a timeout policy for each element in the observable sequence, using the specified scheduler to run timeout timers. If the next element isn't received within the specified timeout duration starting from its predecessor, the other observable sequence is used to produce future messages from that point on.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter other: Sequence to return in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: The source sequence switching to the other sequence in case of a timeout.
     */
    public func timeout(_ dueTime: RxTimeInterval,
                        other: TreatableSequence<Trait, Element, Failure>,
                        scheduler: SchedulerType) -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence<Trait, Element, Failure>(raw: treatableSequence.source
            .timeout(dueTime, other: other.source, scheduler: scheduler))
    }
}

extension TreatableSequence where Trait == TreatableTrait {
    /**
     Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter failure: Failure value in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: An observable sequence with a `RxError.timeout` in case of a timeout.
     */
    public func timeout(_ dueTime: RxTimeInterval, failure: Failure, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        timeout(dueTime, other: .failure(failure), scheduler: scheduler)
    }
}

extension TreatableSequence where Trait == SingleTrait {
    /**
     Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter failure: Failure value in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: An observable sequence with a `RxError.timeout` in case of a timeout.
     */
    public func timeout(_ dueTime: RxTimeInterval, failure: Failure, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        timeout(dueTime, other: .failure(failure), scheduler: scheduler)
    }
}

extension TreatableSequence where Trait == MaybeTrait {
    /**
     Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter failure: Failure value in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: An observable sequence with a `RxError.timeout` in case of a timeout.
     */
    public func timeout(_ dueTime: RxTimeInterval, failure: Failure, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        timeout(dueTime, other: .failure(failure), scheduler: scheduler)
    }
}

extension TreatableSequence where Trait == CompletableTrait, Element == Swift.Never {
    /**
     Applies a timeout policy for each element in the observable sequence. If the next element isn't received within the specified timeout duration starting from its predecessor, a TimeoutError is propagated to the observer.

     - seealso: [timeout operator on reactivex.io](http://reactivex.io/documentation/operators/timeout.html)

     - parameter dueTime: Maximum duration between values before a timeout occurs.
     - parameter failure: Failure value in case of a timeout.
     - parameter scheduler: Scheduler to run the timeout timer on.
     - returns: An observable sequence with a `RxError.timeout` in case of a timeout.
     */
    public func timeout(_ dueTime: RxTimeInterval, failure: Failure, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        timeout(dueTime, other: .failure(failure), scheduler: scheduler)
    }
}

extension TreatableSequenceType where Element: RxAbstractInteger {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter scheduler: Scheduler to run timers on.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    public static func timer(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> TreatableSequence<Trait, Element, Failure> {
        TreatableSequence<Trait, Element, Failure>(raw: Observable<Element>.timer(dueTime, scheduler: scheduler))
    }
}
