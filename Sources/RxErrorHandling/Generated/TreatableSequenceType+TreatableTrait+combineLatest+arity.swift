// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  TreatableSequenceType+combineLatest+arity.swift
//  RxErrorHandling
//
//  Created by Fabian Mücke on 06.07.20.
//

import RxSwift

extension TreatableSequenceType where Trait == TreatableTrait {
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
        resultSelector: @escaping (O1.Element, O2.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element, O4.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType, 
        O7: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
            _ source7: O7,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType, 
        O7: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
            _ source7: O7
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable()
        ))
    }
    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType, 
        O7: TreatableSequenceType, 
        O8: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
            _ source7: O7,
            _ source8: O8,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element, O8.Element) -> Element
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure,
        O8.Element == Element, O8.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable(),
                source8.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func combineLatest
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType, 
        O4: TreatableSequenceType, 
        O5: TreatableSequenceType, 
        O6: TreatableSequenceType, 
        O7: TreatableSequenceType, 
        O8: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
            _ source7: O7,
            _ source8: O8
    ) -> TreatableSequence<Trait, (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element, O8.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure,
        O8.Element == Element, O8.Failure == Failure
     {
        TreatableSequence(raw: Observable.combineLatest(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable(),
                source8.asObservable()
        ))
    }
}
