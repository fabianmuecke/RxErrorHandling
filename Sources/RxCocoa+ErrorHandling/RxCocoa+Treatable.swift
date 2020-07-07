//
//  RxCocoa+Treatable.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxCocoa
@testable import RxErrorHandling

extension SharedSequenceConvertibleType where SharingStrategy == SignalSharingStrategy {
    func asTreatable() -> Treatable<Element, Never> {
        Treatable(raw: asObservable())
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    func asTreatable() -> Treatable<Element, Never> {
        Treatable(raw: asObservable())
    }
}

extension TreatableSequenceType where Failure == Never {
    func asSignal() -> Signal<Element> {
        asSignal(onErrorSignalWith: .empty())
    }

    func asDriver() -> Driver<Element> {
        asDriver(onErrorDriveWith: .empty())
    }
}

extension TreatableSequenceType {
    func asSignal() -> Signal<Result<Element, Failure>> {
        asObservableResult().asSignal(onErrorSignalWith: .empty())
    }

    func asDriver() -> Driver<Result<Element, Failure>> {
        asObservableResult().asDriver(onErrorDriveWith: .empty())
    }

    func asSignal(onFailureRecover: @escaping (Failure) -> Signal<Element>) -> Signal<Element> {
        asSignal(onErrorRecover: { failure in onFailureRecover(failure as! Failure) })
    }

    func asDriver(onFailureRecover: @escaping (Failure) -> Driver<Element>) -> Driver<Element> {
        asDriver(onErrorRecover: { failure in onFailureRecover(failure as! Failure) })
    }
}
