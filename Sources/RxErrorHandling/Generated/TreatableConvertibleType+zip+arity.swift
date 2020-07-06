// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  TreatableConvertibleType+zip+arity.swift
//  RxErrorHandling
//
//  Created by Fabian Mücke on 06.07.20.
//

import RxSwift

extension TreatableConvertibleType {
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
        resultSelector: @escaping (O1.Element, O2.Element) -> Element
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2
    ) -> Treatable<(O1.Element, O2.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element) -> Element
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3
    ) -> Treatable<(O1.Element, O2.Element, O3.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element) -> Element
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4
    ) -> Treatable<(O1.Element, O2.Element, O3.Element, O4.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element) -> Element
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5
    ) -> Treatable<(O1.Element, O2.Element, O3.Element, O4.Element, O5.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element) -> Element
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
            resultSelector: resultSelector
        ))
    }

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6
    ) -> Treatable<(O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType, 
        O7: TreatableConvertibleType
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
    ) -> Treatable<Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure
     {
        Treatable(raw: Observable.zip(
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

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType, 
        O7: TreatableConvertibleType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
            _ source4: O4,
            _ source5: O5,
            _ source6: O6,
            _ source7: O7
    ) -> Treatable<(O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element), Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure,
        O7.Element == Element, O7.Failure == Failure
     {
        Treatable(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable()
        ))
    }
    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType, 
        O7: TreatableConvertibleType, 
        O8: TreatableConvertibleType
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
    ) -> Treatable<Element, Failure>
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
        Treatable(raw: Observable.zip(
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

    public static func zip
    <
        O1: TreatableConvertibleType, 
        O2: TreatableConvertibleType, 
        O3: TreatableConvertibleType, 
        O4: TreatableConvertibleType, 
        O5: TreatableConvertibleType, 
        O6: TreatableConvertibleType, 
        O7: TreatableConvertibleType, 
        O8: TreatableConvertibleType
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
    ) -> Treatable<(O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element, O8.Element), Failure>
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
        Treatable(raw: Observable.zip(
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
