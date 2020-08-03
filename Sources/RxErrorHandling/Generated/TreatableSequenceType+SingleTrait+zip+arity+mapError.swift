// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  TreatableSequenceType+zip+arity.swift
//  RxErrorHandling
//
//  Created by Fabian Mücke on 06.07.20.
//

import RxSwift

extension TreatableSequenceType where Trait == SingleTrait {
    public static func zip
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
        resultSelector: @escaping (O1.Element, O2.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure
     {
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
            resultSelector: { element1, element2 in
                do {
                    return try resultSelector(element1, element2)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
    <
        O1: TreatableSequenceType, 
        O2: TreatableSequenceType, 
        O3: TreatableSequenceType
    >
    (
            _ source1: O1,
            _ source2: O2,
            _ source3: O3,
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure
     {
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
            resultSelector: { element1, element2, element3 in
                do {
                    return try resultSelector(element1, element2, element3)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
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
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure
     {
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
            resultSelector: { element1, element2, element3, element4 in
                do {
                    return try resultSelector(element1, element2, element3, element4)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
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
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure
     {
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
            resultSelector: { element1, element2, element3, element4, element5 in
                do {
                    return try resultSelector(element1, element2, element3, element4, element5)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
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
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
    ) -> TreatableSequence<Trait, Element, Failure>
    where
        O1.Element == Element, O1.Failure == Failure,
        O2.Element == Element, O2.Failure == Failure,
        O3.Element == Element, O3.Failure == Failure,
        O4.Element == Element, O4.Failure == Failure,
        O5.Element == Element, O5.Failure == Failure,
        O6.Element == Element, O6.Failure == Failure
     {
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
            resultSelector: { element1, element2, element3, element4, element5, element6 in
                do {
                    return try resultSelector(element1, element2, element3, element4, element5, element6)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
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
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
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
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable(),
            resultSelector: { element1, element2, element3, element4, element5, element6, element7 in
                do {
                    return try resultSelector(element1, element2, element3, element4, element5, element6, element7)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

    public static func zip
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
        resultSelector: @escaping (O1.Element, O2.Element, O3.Element, O4.Element, O5.Element, O6.Element, O7.Element, O8.Element) throws -> Element,
        mapError: @escaping (Error) -> Failure
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
        TreatableSequence(raw: Observable.zip(
                source1.asObservable(),
                source2.asObservable(),
                source3.asObservable(),
                source4.asObservable(),
                source5.asObservable(),
                source6.asObservable(),
                source7.asObservable(),
                source8.asObservable(),
            resultSelector: { element1, element2, element3, element4, element5, element6, element7, element8 in
                do {
                    return try resultSelector(element1, element2, element3, element4, element5, element6, element7, element8)
                } catch {
                    throw mapError(error)
                }
            }
        ))
    }

}
