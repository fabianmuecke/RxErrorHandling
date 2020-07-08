import Foundation
import Nimble
import Quick
import QuickSwiftCheck
import RxBlocking
@testable import RxErrorHandling
import RxNimbleRxBlocking
import RxSwift
import SwiftCheck

final class RxErrorHandlingTests: QuickSpec {
    override func spec() {
        describe("RxErrorHandlingTests") {
            context("Errors") {
                sc_it("should catch errors from asTreatable") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let source = valuesToObservable(values)

                        // WHEN
                        let treatable = source.asTreatable(mapError: { anyError -> TestError in
                            switch anyError {
                            case InitialError.someExternalError:
                                return .some
                            default:
                                return .other
                            }
                        })

                        return expect(treatable.asObservable())
                            .materialized(timeout: waitTime(values).timeInterval)
                            .sc_to(equal(expectedValues(values, mapError: { initialError -> TestError in
                                switch initialError {
                                case InitialError.someExternalError:
                                    return .some
                                default:
                                    return .other
                                }
                            })))
                    }
                }

                sc_it("should catch errors from Treatable.create") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let treatable = valuesToTreatable(values)

                        // THEN
                        return expect(treatable.asObservable())
                            .materialized(timeout: waitTime(values).timeInterval)
                            .sc_to(equal(expectedValues(values, mapError: { $0 })))
                    }
                }

                sc_it("should map errors from asTreatable") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let source = valuesToObservable(values)

                        // WHEN
                        let treatable = source.asTreatable(mapError: { anyError -> TestError in
                            switch anyError {
                            case InitialError.someExternalError:
                                return .some
                            default:
                                return .other
                            }
                        }).mapError { (error: TestError) -> TestError2 in
                            switch error {
                            case .some:
                                return .some2
                            case .other:
                                return .other2
                            }
                        }

                        // THEN
                        return expect(treatable.asObservable())
                            .materialized(timeout: waitTime(values).timeInterval)
                            .sc_to(equal(expectedValues(values, mapError: { initialError -> TestError2 in
                                switch initialError {
                                case InitialError.someExternalError:
                                    return .some2
                                default:
                                    return .other2
                                }
                            })))
                    }
                }

                sc_it("should map errors from Treatable.create") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let treatable = valuesToTreatable(values)

                        // WHEN
                        let mapped = treatable.mapError { (error: InitialError) -> TestError in
                            switch error {
                            case .someExternalError:
                                return .some
                            case .otherExternalError:
                                return .other
                            }
                        }

                        // THEN
                        return expect(mapped.asObservable())
                            .materialized()
                            .sc_to(equal(expectedValues(values, mapError: { initialError -> TestError in
                                switch initialError {
                                case InitialError.someExternalError:
                                    return .some
                                default:
                                    return .other
                                }
                            })))
                    }
                }
            }
        }
    }
}

private func expectedValues<Failure: Swift.Error>(
    _ values: [TestValue<Int, InitialError>],
    mapError: (InitialError) -> Failure
) -> MaterializedSequenceResult<Int> {
    values.reduce(MaterializedSequenceResult<Int>.completed(elements: [])) { result, value in
        guard case let .completed(elements: elements) = result else {
            return result
        }
        switch value {
        case .next(let value, after: _):
            return .completed(elements: elements + [value])
        case .error(let error, after: _):
            return .failed(elements: elements, error: mapError(error))
        }
    }
}

private func valuesToObservable(_ values: [TestValue<Int, InitialError>]) -> Observable<Int> {
    Observable.create { observer in
        callObserver(observer: observer, values: values)

        return Disposables.create()
    }
}

private func callObserver(observer: AnyObserver<Int>, values: [TestValue<Int, InitialError>]) {
    if let first = values.first {
        var values = values
        values.remove(at: 0)
        first.call(in: observer, callback: { callObserver(observer: observer, values: values) })
    } else {
        observer.onCompleted()
    }
}

private func valuesToTreatable<Element: Arbitrary,
                               Failure>(_ values: [TestValue<Element, Failure>]) -> Treatable<Element, Failure> {
    Treatable.create { observer in
        callObserver(observer: observer, values: values, anyErrors: values.contains(where: {
            switch $0 {
            case .next: return false
            case .error: return true
            }
        }))
        return Disposables.create()
    }
}

private func callObserver<Element: Arbitrary, Failure>(observer: @escaping Treatable<Element, Failure>.Observer,
                                                       values: [TestValue<Element, Failure>],
                                                       anyErrors: Bool) {
    if let first = values.first {
        var values = values
        values.remove(at: 0)
        first.call(in: observer, callback: { callObserver(observer: observer, values: values, anyErrors: anyErrors) })
    } else {
        if !anyErrors {
            observer(.completed(.finished))
        }
    }
}

private func waitTime(_ values: [TestValue<Int, InitialError>]) -> DispatchTimeInterval {
    .milliseconds(100 + values.reduce(0) { result, next in
        switch next {
        case let .next(_, after: interval),
             let .error(_, after: interval):
            switch interval {
            case let .milliseconds(ms):
                return result + ms
            default:
                return result
            }
        }
    })
}

extension DispatchTimeInterval {
    var timeInterval: TimeInterval {
        switch self {
        case let .seconds(value):
            return Double(value)
        case let .milliseconds(value):
            return Double(value) * 0.001
        case let .microseconds(value):
            return Double(value) * 0.000001
        case let .nanoseconds(value):
            return Double(value) * 0.000000001
        case .never:
            return Double.max
        default:
            return 0
        }
    }
}

/// 0 to 10 ms
let intervalGen: Gen<DispatchTimeInterval> = Gen.fromElements(in: 0 ... 10).map(DispatchTimeInterval.milliseconds)

/// Will always produce a success
let nextGen: Gen<TestValue<Int, InitialError>> = Gen.compose { composer in
    .next(composer.generate(), after: composer.generate(using: intervalGen))
}

/// Will produce successes only
let nextsGen: Gen<[TestValue<Int, InitialError>]> = Gen.compose { composer in
    composer.generate(using: nextGen.proliferate(withSize: composer.generate(using: Gen.fromElements(in: 1 ... 5))))
}

/// Will always produce an error
let errorGen: Gen<TestValue<Int, InitialError>> = Gen.compose { composer in
    .error(composer.generate(), after: composer.generate(using: intervalGen))
}

/// Will always end with an error
let errorsGen: Gen<[TestValue<Int, InitialError>]> = Gen.compose { composer in
    let nexts = composer
        .generate(using: nextGen.proliferate(withSize: composer.generate(using: Gen.fromElements(in: 0 ... 5))))
    return nexts + [composer.generate(using: errorGen)]
}

extension DispatchTimeInterval: Arbitrary {
    public static var arbitrary: Gen<DispatchTimeInterval> {
        Gen.compose { composer in
            composer.generate(using:
                Gen.fromElements(of: [
                    .seconds(composer.generate()),
                    .milliseconds(composer.generate()),
                    .microseconds(composer.generate()),
                    .nanoseconds(composer.generate()),
                    .never,
                ])
            )
        }
    }
}

enum TestValue<Element: Arbitrary, Failure: Swift.Error>: Arbitrary where Failure: Arbitrary {
    case next(Element, after: DispatchTimeInterval)
    case error(Failure, after: DispatchTimeInterval)

    func call(in observer: AnyObserver<Element>, callback: @escaping () -> Void) {
        switch self {
        case let .next(element, after: interval):
            after(interval) {
                observer.onNext(element)
                callback()
            }
        case let .error(error, after: interval):
            after(interval) {
                observer.onError(error)
                callback()
            }
        }
    }

    func call(in observer: @escaping Treatable<Element, Failure>.Observer, callback: @escaping () -> Void) {
        switch self {
        case let .next(element, after: interval):
            after(interval) {
                observer(.next(element))
                callback()
            }
        case let .error(error, after: interval):
            after(interval) {
                observer(.completed(.failure(error)))
                callback()
            }
        }
    }

    static var arbitrary: Gen<TestValue<Element, Failure>> {
        Gen.compose { composer in
            composer.generate(using: Gen.fromElements(of: [
                .next(composer.generate(), after: composer.generate()),
                .error(composer.generate(), after: composer.generate()),
            ]))
        }
    }
}

private func after(_ interval: DispatchTimeInterval, _ execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: execute)
}

enum InitialError: Swift.Error, Arbitrary, CaseIterable {
    case someExternalError
    case otherExternalError
}

enum TestError: Swift.Error, Equatable {
    case some
    case other
}

enum TestError2: Swift.Error, Equatable {
    case some2
    case other2
}

extension CaseIterable where AllCases.Index: RandomType {
    public static var arbitrary: Gen<Self> {
        Gen.fromElements(of: Self.allCases)
    }
}

extension Expectation where T: ObservableConvertibleType {
    func materialized(timeout: TimeInterval? = nil) -> Expectation<MaterializedSequenceResult<T.Element>> {
        Expectation<MaterializedSequenceResult<T.Element>>(expression: expression.cast { source in
            source?.toBlocking(timeout: timeout).materialize()
        })
    }
}

extension MaterializedSequenceResult: Equatable where T: Equatable {
    public static func == (lhs: MaterializedSequenceResult<T>, rhs: MaterializedSequenceResult<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.completed(elements: left), .completed(elements: right)):
            return left == right
        case let (.failed(elements: left, error: leftError), .failed(elements: right, error: rightError)):
            return left == right && leftError.localizedDescription == rightError.localizedDescription
        default:
            return false
        }
    }
}
