//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public struct Treatable<Element, Failure: Error>: TreatableConvertibleType {
    public enum Completion {
        case finished
        case failure(Failure)
    }

    let source: Observable<Element>

    init(raw: Observable<Element>) {
        source = raw
    }

    init(source: Observable<Element>, mapError: @escaping (Error) -> Failure) {
        self.source = source.catchError { error in
            .error(mapError(error))
        }
    }

    public func asTreatable() -> Treatable<Element, Failure> {
        self
    }

    public func asObservable() -> Observable<Element> {
        source
    }

    public func asObservableResult() -> Observable<Result<Element, Failure>> {
        asObservable().map(Result<Element, Failure>.success).catchError { .just(.failure($0 as! Failure)) }
    }
}

extension Treatable {
    public static func empty() -> Self {
        .init(raw: .empty())
    }

    public static func never() -> Self {
        .init(raw: .never())
    }

    public static func just(_ element: Element) -> Self {
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

    public static func of(_ elements: Element...) -> Self {
        .init(raw: Observable.from(elements))
    }
}

extension Treatable {
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
                      onCompleted: @escaping (Completion) -> Void,
                      onDisposed: (() -> Void)? = nil) -> Disposable {
        asObservable()
            .subscribe(onNext: { onNext($0) },
                       onError: { onCompleted(.failure($0 as! Failure)) },
                       onCompleted: { onCompleted(.finished) },
                       onDisposed: onDisposed)
    }
}
