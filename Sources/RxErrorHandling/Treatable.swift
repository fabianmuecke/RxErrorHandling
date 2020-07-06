//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public struct Treatable<Success, Failure: Error>: TreatableConvertibleType {
    public typealias Element = Success

    public enum Completion {
        case finished
        case failure(Failure)
    }

    let source: Observable<Element>

    init(raw: Observable<Element>) {
        source = raw
    }

    init(source: Observable<Success>, errorTransform: @escaping (Error) -> Failure) {
        self.source = source.catchError { error in
            .error(errorTransform(error))
        }
    }

    public func asObservable() -> Observable<Element> {
        source
    }

    public func asObservableResult() -> Observable<Result<Success, Failure>> {
        asObservable().map(Result<Success, Failure>.success).catchError { .just(.failure($0 as! Failure)) }
    }
}

extension Treatable {
    public static func empty() -> Self {
        .init(raw: .empty())
    }

    public static func never() -> Self {
        .init(raw: .never())
    }

    public static func just(_ element: Success) -> Self {
        .init(raw: .just(element))
    }

    public static func error(_ error: Failure) -> Self {
        .init(raw: .error(error))
    }

    public static func deferred(_ observableFactory: @escaping () -> Self) -> Self {
        .init(raw: Observable.deferred {
            observableFactory().asObservable()
        })
    }

    public static func of(_ elements: Success...) -> Self {
        .init(raw: Observable.from(elements))
    }
}

extension Treatable {
    public func treat<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Observer.Element == Result<Success, Failure> {
        asObservableResult().subscribe(observer)
    }

    public func treat<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Success == Observer.Element,
        Failure == Never {
        asObservable().subscribe(observer)
    }

    public func treat(onNext: @escaping (Success) -> Void,
                      onCompleted: @escaping (Completion) -> Void,
                      onDisposed: (() -> Void)? = nil) -> Disposable {
        asObservable()
            .subscribe(onNext: { onNext($0) },
                       onError: { onCompleted(.failure($0 as! Failure)) },
                       onCompleted: { onCompleted(.finished) },
                       onDisposed: onDisposed)
    }
}
