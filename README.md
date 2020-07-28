# RxErrorHandling

## DO NOT USE IN PRODUCTION

This is a proof of concept, for now, which is neither battle tested nor production ready.

## What
RxErrorHandling introduces `Treatable` traits for [RxSwift](https://github.com/ReactiveX/RxSwift). These feature [Combine](https://developer.apple.com/documentation/combine)-like error handling with the error type of an Rx sequence being part of the signature and enforcing the handling of errors.

I'm very aware that the name is awkward and any suggestions for a better name are very welcome.

## Usage in a nutshell

### Creating Treatables
Use `create` function (like for `Single` or `Observable`) to create a `Treatable` or make any `ObservableType` a `Treatable` using `asTreatable`:

```
enum FooError: Error {
    case foo
    case otherFoo
}

enum BarError: Error {
    case bar
    case otherBar
}

// Use create function
let foo = Treatable<String, FooError>.create { treatable in
    guard precondition else {
        treatable(.completed(.failure(.foo)))
        return
    }

    while whatever {
        guard otherPrecondition else {
            treatable(.completed(.failure(.otherFoo)))
            return
        }
        
        treatable(.next(nextValue))
    }
    treatable(.completed(.finished))
}

// Or asTreatable with error mapping (here: someObservable: Observable<String>)
let bar = someObservable.asTreatable(mapError: { error in
    error as? BarError ?? .otherBar
})
```

### Mapping and combining

Use all known functions from Observable, Single, Signal etc. and additionally use `mapError` to map or unify error types.
```
enum CombinedError: Error {
    case foo
    case bar
    case other
}

// Map error types to match, when combining sequences
let merged = Treatable<String, CombinedError>.merge(
    foo.mapError { fooError in 
        switch fooError {
            case .foo: return .foo
            case .otherFoo: return .other
        }
    },
    bar.mapError { barError in 
        switch barError {
            case .bar: return .bar
            case .otherBar: return .other
        }
    }
)
```

Or map back to an observable for compatibility with e.g. existing libraries.
```
let someTreat: Treatable<Success, Failure>
let infallibleObservable: Observable<Result<Success, Failure>> = someTreat.asResultObservable()
let fallibleObservable: Observable<Success> = someTreat.asObservable()
```

### Result handling

Use the `treat` function to handle results:
```
// Use treat function to handle results
merged.treat(onNext: { value in
    // handle next value
}, onCompleted: { completion in
    switch completion {
    case .failure(.foo): break // handle error
    case .failure(.bar): break // handle error
    case .failure(.other): break // handle error
    case .finished: break // handle success
    }
})

let noErrors: Treatable<Element, Never>
noErrors.treat(myObserver) // just use any ObserverType

let mayHaveErrors: Treatable<Result<Success, Failure>, Failure>
mayHaveErrors.treat(myObserver) // use any ObserverType with Element == Result<Success, Failure>
```

### Available Treatable Traits
* `Treatable`
* `TreatableSingle`
* `TreatableMaybe`
* `TreatableCompletable`
