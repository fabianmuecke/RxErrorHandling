//
//  TreatableSingle.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension SingleTrait: PrimitiveTreatableTrait {}

public typealias TreatableSingle<Element, Failure: Swift.Error> = TreatableSequence<SingleTrait,
                                                                                    Element,
                                                                                    Failure>

public enum TreatableSingleEvent<Element, Failure: Swift.Error> {
    case success(Element)
    case failure(Failure)
}

extension TreatableSequence where Trait == SingleTrait {
    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> Self {
        .init(raw: Single.never())
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element) -> Self {
        .init(raw: Single.just(element))
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> Self {
        .init(raw: Observable.just(element, scheduler: scheduler))
    }

    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func error(_ error: Failure) -> Self {
        .init(raw: Single.error(error))
    }
}

extension TreatableSequence where Trait == SingleTrait {
    public typealias SingleObserver = (TreatableSingleEvent<Element, Failure>) -> Void

    public static func create(subscribe: @escaping (@escaping SingleObserver) -> Disposable)
        -> Treatable<Element, Failure> {
        let source = Observable<Element>.create { observer in
            subscribe { event in
                switch event {
                case let .success(element):
                    observer.onNext(element)
                    observer.onCompleted()
                case let .failure(failure):
                    observer.onError(failure)
                }
            }
        }

        return Treatable(raw: source)
    }
}

extension TreatableSequence where Trait == SingleTrait {
    public func treat(_ observer: @escaping SingleObserver) -> Disposable {
        var stopped = false
        return treatableSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true

            switch event {
            case let .next(element):
                observer(.success(element))
            case let .error(error):
                observer(.failure(error as! Failure))
            case .completed:
                rxFatalErrorInDebug("Completed should never occur")
            }
        }
    }
}

extension TreatableSequence where Trait == SingleTrait, Failure == Never {
    public func treat(onSuccess: @escaping (Element) -> Void) -> Disposable {
        treatableSequence.treat { (event: TreatableSingleEvent) in
            switch event {
            case let .success(element):
                onSuccess(element)
            case let .failure(failure):
                rxFatalErrorInDebug("This error should never occur: \(failure)")
            }
        }
    }
}
