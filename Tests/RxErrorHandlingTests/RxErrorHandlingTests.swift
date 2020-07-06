import Foundation
import Nimble
import Quick
@testable import RxErrorHandling
import RxSwift
import RxTest

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

                it("Should catch some error") {
                    let source = Observable<Int>.create { observable in
                        observable.onNext(1)
                        after(.milliseconds(5)) { observable.onNext(2) }
                        after(.milliseconds(5)) { observable.onError(InitialError.someExternalError) }
                        return Disposables.create()
                    }

                    let treatable = Treatable(source: source, errorTransform: { anyError -> TestError in
                        switch anyError {
                        case InitialError.someExternalError:
                            return .some
                        default:
                            return .other
                        }
                    })

                    let observer = scheduler.createObserver(Result<Int, TestError>.self)
                    treatable.treat(observer).disposed(by: running)
                    expect(observer.events.map { $0.value }).toEventually(equal([
                        .next(.success(1)),
                        .next(.success(2)),
                        .next(.failure(.some)),
                        .completed,
                    ]))
                }
                
                it("Should catch other error") {
                    let source = Observable<Int>.create { observable in
                        observable.onNext(1)
                        after(.milliseconds(5)) { observable.onNext(2) }
                        after(.milliseconds(5)) { observable.onError(InitialError.otherExternalError) }
                        return Disposables.create()
                    }

                    let treatable = Treatable(source: source, errorTransform: { anyError -> TestError in
                        switch anyError {
                        case InitialError.someExternalError:
                            return .some
                        default:
                            return .other
                        }
                    })

                    let observer = scheduler.createObserver(Result<Int, TestError>.self)
                    treatable.treat(observer).disposed(by: running)
                    expect(observer.events.map { $0.value }).toEventually(equal([
                        .next(.success(1)),
                        .next(.success(2)),
                        .next(.failure(.other)),
                        .completed,
                    ]))
                }
                
                it("Should map some error") {
                    let source = Observable<Int>.create { observable in
                        observable.onNext(1)
                        after(.milliseconds(5)) { observable.onNext(2) }
                        after(.milliseconds(5)) { observable.onError(InitialError.someExternalError) }
                        return Disposables.create()
                    }

                    let treatable = Treatable(source: source, errorTransform: { anyError -> TestError in
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

                    let observer = scheduler.createObserver(Result<Int, TestError2>.self)
                    treatable.treat(observer).disposed(by: running)
                    expect(observer.events.map { $0.value }).toEventually(equal([
                        .next(.success(1)),
                        .next(.success(2)),
                        .next(.failure(.some2)),
                        .completed,
                    ]))
                }
            }
        }
    }
}

private func after(_ interval: DispatchTimeInterval, _ execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: execute)
}

enum InitialError: Swift.Error {
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
