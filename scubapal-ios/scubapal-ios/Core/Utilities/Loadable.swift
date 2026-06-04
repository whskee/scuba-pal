enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case let .loaded(value) = self { value } else { nil }
    }

    var errorMessage: String? {
        if case let .failed(message) = self { message } else { nil }
    }
}
