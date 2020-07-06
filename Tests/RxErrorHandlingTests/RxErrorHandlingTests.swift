import Foundation
import Nimble
import Quick
import QuickSwiftCheck
@testable import RxErrorHandling
import RxSwift
import RxTest
import SwiftCheck

final class RxErrorHandlingTests: QuickSpec {
    override func spec() {
        describe("RxErrorHandlingTests") {
            context("Errors") {
                var scheduler: TestScheduler!
                var running: DisposeBag!

                beforeEach {
                    scheduler = TestScheduler(initialClock: 0)
                    running = DisposeBag()
                }

                sc_it("Should catch errors") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let source = valuesToObservable(values)
                        let treatable = source.asTreatable(catchError: { anyError -> TestError in
                            switch anyError {
                            case InitialError.someExternalError:
                                return .some
                            default:
                                return .other
                            }
                        })

                        // WHEN
                        let observer = scheduler.createObserver(Result<Int, TestError>.self)
                        treatable.treat(observer).disposed(by: running)
                        waitFor(values)

                        // THEN
                        return expect(observer.events.map { $0.value })
                            .sc_to(equal(expectedValues(values, mapError: { initialError in
                                switch initialError {
                                case InitialError.someExternalError:
                                    return .some
                                default:
                                    return .other
                                }
                            })))
                    }
                }

                sc_it("Should map errors") {
                    forAll(errorsGen) { (values: [TestValue<Int, InitialError>]) in
                        // GIVEN
                        let source = valuesToObservable(values)
                        let treatable = source.asTreatable(catchError: { anyError -> TestError in
                            switch anyError {
                            case InitialError.someExternalError:
                                return .some
                            default:
                                return .other
                            }
                        })

                        // WHEN
                        let observer = scheduler.createObserver(Result<Int, TestError2>.self)
                        treatable
                            .mapError { (error: TestError) -> TestError2 in
                                switch error {
                                case .some:
                                    return .some2
                                case .other:
                                    return .other2
                                }
                            }
                            .treat(observer)
                            .disposed(by: running)
                        waitFor(values)

                        // THEN
                        return expect(observer.events.map { $0.value })
                            .sc_to(equal(expectedValues(values, mapError: { initialError in
                                switch initialError {
                                case InitialError.someExternalError:
                                    return .some2
                                default:
                                    return .other2
                                }
                            })))
                    }
                }
            }
        }
    }
}

private func expectedValues<Failure>(_ values: [TestValue<Int, InitialError>],
                                     mapError: (InitialError) -> Failure) -> [RxSwift.Event<Result<Int, Failure>>] {
    values.map { value in
        switch value {
        case .next(let value, after: _):
            return .next(.success(value))
        case .error(let error, after: _):
            return .next(.failure(mapError(error)))
        }
    } + [.completed]
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

private func waitFor(_ values: [TestValue<Int, InitialError>]) {
    var finished = false
    after(waitTime(values)) { finished = true }
    while !finished {
        RunLoop.current.run(mode: .default, before: Date.distantFuture)
    }
}

private func waitTime(_ values: [TestValue<Int, InitialError>]) -> DispatchTimeInterval {
    .milliseconds(10 + values.reduce(0) { result, next in
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

enum TestValue<Success: Arbitrary, Failure: Swift.Error>: Arbitrary where Failure: Arbitrary {
    case next(Success, after: DispatchTimeInterval)
    case error(Failure, after: DispatchTimeInterval)

    func call(in observer: AnyObserver<Success>, callback: @escaping () -> Void) {
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

    static var arbitrary: Gen<TestValue<Success, Failure>> {
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
