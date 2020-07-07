//
//  Treatable.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public enum TreatableTrait {}

public typealias Treatable<Element, Failure: Swift.Error> = TreatableSequence<TreatableTrait, Element, Failure>

public enum TreatableEvent<Element, Failure: Swift.Error> {
    case next(Element)
    case completed(Completion)

    public enum Completion {
        case finished
        case failure(Failure)
    }
}

extension TreatableSequence where Trait == TreatableTrait {
    public static func empty() -> Self {
        .init(raw: Observable.empty())
    }

    public static func never() -> Self {
        .init(raw: Observable.never())
    }

    public static func just(_ element: Element) -> Self {
        .init(raw: Observable.just(element))
    }

    public static func error(_ error: Failure) -> Self {
        .init(raw: Observable.error(error))
    }

    public static func of(_ elements: Element...) -> Self {
        .init(raw: Observable.from(elements))
    }
}

extension TreatableSequence where Trait == TreatableTrait {
    /**
     This method converts an array to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from(_ array: [Element],
                            scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Self {
        Treatable(raw: Observable.from(array, scheduler: scheduler))
    }

    /**
     This method converts a sequence to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from<Sequence: Swift.Sequence>(
        _ sequence: Sequence,
        scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance
    ) -> Self where Sequence.Element == Element {
        Treatable(raw: Observable.from(sequence, scheduler: scheduler))
    }

    /**
     This method converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.

     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    public static func from(optional: Element?,
                            scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Self {
        Treatable(raw: Observable.from(optional: optional, scheduler: scheduler))
    }
}

extension TreatableSequence where Trait == TreatableTrait {
    public typealias Observer = (TreatableEvent<Element, Failure>) -> Void

    public static func create(subscribe: @escaping (@escaping Observer) -> Disposable)
        -> Treatable<Element, Failure> {
        let source = Observable<Element>.create { observer in
            subscribe { event in
                switch event {
                case let .next(element):
                    observer.on(.next(element))
                case .completed(.finished):
                    observer.on(.completed)
                case let .completed(.failure(failure)):
                    observer.on(.error(failure))
                }
            }
        }

        return Treatable(raw: source)
    }
}

extension TreatableSequence where Element: RxAbstractInteger, Trait == TreatableTrait {
    /**
     Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

     - parameter period: Period for producing the values in the resulting sequence.
     - returns: An observable sequence that produces a value after each period.
     */
    public static func interval(_ period: RxTimeInterval, scheduler: SchedulerType) -> Self {
        Treatable(raw: Observable.interval(period, scheduler: scheduler))
    }
}

// MARK: timer

extension TreatableSequence where Element: RxAbstractInteger, Trait == TreatableTrait {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter period: Period to produce subsequent values.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    public static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval, scheduler: SchedulerType)
        -> Self {
        Treatable(raw: Observable.timer(dueTime, period: period, scheduler: scheduler))
    }
}

extension TreatableSequence where Trait == TreatableTrait {
    public func treat<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Observer.Element == Result<Element, Failure> {
        asObservableResult().subscribe(observer)
    }

    public func treat<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Element == Observer.Element,
        Failure == Never {
        asObservable().subscribe(observer)
    }

    public func treat(onNext: @escaping (Element) -> Void,
                      onCompleted: @escaping (TreatableEvent<Element, Failure>.Completion) -> Void,
                      onDisposed: (() -> Void)? = nil) -> Disposable {
        asObservable().subscribe(onNext: { onNext($0) },
                                 onError: { onCompleted(.failure($0 as! Failure)) },
                                 onCompleted: { onCompleted(.finished) },
                                 onDisposed: onDisposed)
    }
}
