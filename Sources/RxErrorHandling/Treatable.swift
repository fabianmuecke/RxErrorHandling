//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public struct Treatable<Success, Failure: Error>: TreatableType {
    public typealias Element = Result<Success, Failure>

    public enum Completion {
        case finished
        case failure(Failure)
    }

    let source: Observable<Element>

    init(raw: Observable<Element>) {
        source = raw
    }

    init(source: Observable<Success>, errorTransform: @escaping (Error) -> Failure) {
        self.source = source.map { .success($0) }.catchError { error in
            .just(.failure(errorTransform(error)))
        }
    }

    public func unsafeFromSuccess() -> Observable<Success> {
        source.flatMap { element -> Observable<Success> in
            switch element {
            case let .success(result):
                return .just(result)
            case let .failure(error):
                return .error(error)
            }
        }
    }

    public func asObservable() -> Observable<Element> {
        source
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
        .init(raw: .just(.success(element)))
    }

    public static func error(_ error: Failure) -> Self {
        .init(raw: .just(.failure(error)))
    }

    public static func deferred(_ observableFactory: @escaping () -> Self) -> Self {
        return .init(raw: Observable.deferred {
            observableFactory()
                .asObservable()
            })
    }

    public static func of(_ elements: Success...) -> Self {
        return .init(raw: Observable.from(elements.map { .success($0) }))
    }
}

extension Treatable: ObservableType {
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Element == Observer.Element {
        asObservable().subscribe(observer)
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where
        Observer: ObserverType,
        Success == Observer.Element,
        Failure == Never {
        unsafeFromSuccess().subscribe(observer)
    }

    public func subscribe(onNext: @escaping (Success) -> Void,
                          onCompleted: @escaping (Completion) -> Void,
                          onDisposed: (() -> Void)? = nil) -> Disposable {
        unsafeFromSuccess()
            .subscribe(onNext: { onNext($0) },
                       onError: { onCompleted(.failure($0 as! Failure)) },
                       onCompleted: { onCompleted(.finished) },
                       onDisposed: onDisposed)
    }
}
