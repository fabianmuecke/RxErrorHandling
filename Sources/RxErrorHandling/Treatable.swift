//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

public struct Treatable<Element, Failure: Error>: TreatableType {
    let source: Observable<Result<Element, Failure>>

    init(raw: Observable<Result<Element, Failure>>) {
        source = raw
    }

    init(source: Observable<Element>, errorTransform: @escaping (Error) -> Failure) {
        self.source = source.map { .success($0) }.catchError { error in
            .just(.failure(errorTransform(error)))
        }
    }

    public func asObservable() -> Observable<Element> {
        source.flatMap { element -> Observable<Element> in
            switch element {
            case let .success(result):
                return .just(result)
            case let .failure(error):
                return .error(error)
            }
        }
    }

    public func asSafeObservable() -> Observable<Result<Element, Failure>> {
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

    public static func just(_ element: Element) -> Self {
        .init(raw: .just(.success(element)))
    }

    public static func error(_ error: Failure) -> Self {
        .init(raw: .just(.failure(error)))
    }

    public static func deferred(_ observableFactory: @escaping () -> Self) -> Self {
        return .init(raw: Observable.deferred {
            observableFactory()
                .asObservable()
                .map { .success($0) }
                .catchError { .just(.failure($0 as! Failure)) }
            })
    }

    public static func of(_ elements: Element...) -> Self {
        return .init(raw: Observable.from(elements.map { .success($0) }))
    }
}
