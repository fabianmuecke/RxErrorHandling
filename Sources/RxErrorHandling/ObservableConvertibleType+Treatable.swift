//
//  File.swift
//
//
//  Created by Fabian Mücke on 02.07.20.
//

import RxSwift

extension ObservableConvertibleType {
    public func asTreatable<Failure>(catchError: @escaping (Error) -> Failure) -> Treatable<Element, Failure> {
        Treatable(source: asObservable(), errorTransform: catchError)
    }
}
