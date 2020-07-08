//
//  TreatableCompletable.swift
//
//
//  Created by Fabian Mücke on 07.07.20.
//

import RxSwift

extension TreatableSequenceType where Trait == CompletableTrait, Element == Never {
    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func andThen<NewElement>(_ second: TreatableSingle<NewElement, Failure>)
        -> TreatableSingle<NewElement, Failure> {
        TreatableSingle(raw: treatableSequence.asCompletable().andThen(second.asSingle()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func andThen<Element>(_ second: TreatableMaybe<Element, Failure>) -> TreatableMaybe<Element, Failure> {
        TreatableMaybe(raw: treatableSequence.asCompletable().andThen(second.asMaybe()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func andThen(_ second: TreatableCompletable<Failure>) -> TreatableCompletable<Failure> {
        TreatableCompletable(raw: treatableSequence.asCompletable().andThen(second.asCompletable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func andThen<Element>(_ second: Treatable<Element, Failure>) -> Treatable<Element, Failure> {
        Treatable(raw: treatableSequence.asCompletable().andThen(second.asObservable()))
    }
}
