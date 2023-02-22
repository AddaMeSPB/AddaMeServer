public protocol PropertyNames {
    func propertyNames() -> [String]
}

extension PropertyNames {
    public func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
    }
}
