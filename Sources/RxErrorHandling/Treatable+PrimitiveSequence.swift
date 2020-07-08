//
//  Treatable+PrimitiveSequence.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension TreatableSequenceType where Trait == TreatableTrait {
    /**
     The `asSingle` operator throws a `RxError.noElements` or `RxError.moreThanOneElement`
     if the source Observable does not emit exactly one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element when the source Observable has completed, or throws an exception if more (or none) of them are emitted.
     */
    public func asSingle() -> TreatableSingle<Element, Failure> {
        TreatableSingle(raw: asObservable().asSingle())
    }

    /**
     The `first` operator emits only the very first item emitted by this Observable,
     or nil if this Observable completes without emitting anything.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element or nil if the source observable sequence completes without emitting any items.
     */
    public func first() -> TreatableSingle<Element?, Failure> {
        TreatableSingle(raw: asObservable().first())
    }

    /**
     The `asMaybe` operator throws a `RxError.moreThanOneElement`
     if the source Observable does not emit at most one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element, completes when the source Observable has completed, or throws an exception if more of them are emitted.
     */
    public func asMaybe() -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: asObservable().asMaybe())
    }
}

extension TreatableSequence where Trait == SingleTrait {
    public func asSingle() -> Single<Element> {
        source.asSingle()
    }
}

extension TreatableSequence where Trait == MaybeTrait {
    public func asMaybe() -> Maybe<Element> {
        source.asMaybe()
    }
}

extension TreatableSequence where Trait == CompletableTrait, Element == Never {
    public func asCompletable() -> Completable {
        source.asCompletable()
    }
}

extension TreatableSequenceType where Trait == TreatableTrait, Element == Never {
    /**
     - returns: An observable sequence that completes.
     */
    public func asCompletable() -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: asObservable())
    }
}
