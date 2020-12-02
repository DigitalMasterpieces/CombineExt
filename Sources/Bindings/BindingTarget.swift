//
//  BindingTarget.swift
//  CombineExt
//
//  Created by Frank Schlegel on 30/11/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine

/// A BindingTarget is like a subscriber that knows to manage the subscription itself.
/// Classes implementing this protocol can be target of convenient Publisher
/// bindings and assignments without causing accidental retain cycles.
/// Subscriptions created this way are released together with the target.
///
/// For example:
///
///     aPublisher.bind(to: self) { me, object in
///         me.doSomething(with: object)
///     }
///
///     aPublisher.bind(to: self, keyPath: \.property)
///
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol BindingTarget: AnyObject {
    /// A "bag" to store subscriptions in that should be cancelled
    /// when `self` is deallocated.
    var cancellables: Set<AnyCancellable> { get set }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import ObjectiveC.runtime

/// Extends `NSObject` to provide a `cancellables` Set via associated objects,
/// so that any `NSObject` subtype can be target of bindings.
extension NSObject: BindingTarget {
    private struct AssociatedKeys {
        static var CancellablesKey = "CancellablesKey"
    }

    /// Helper for wrapping the ``Set<AnyCancellable>`` into an (associated) object.
    private final class Wrapped<T> {
        let value: T
        init(_ val: T) {
            value = val
        }
    }

    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var cancellables: Set<AnyCancellable> {
        get {
            if let cancellables = objc_getAssociatedObject(self, &NSObject.AssociatedKeys.CancellablesKey) as? Wrapped<Set<AnyCancellable>> {
                return cancellables.value
            } else {
                let cancellables = Set<AnyCancellable>()
                objc_setAssociatedObject(self, &NSObject.AssociatedKeys.CancellablesKey, Wrapped(cancellables), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cancellables
            }
        }
        set {
            objc_setAssociatedObject(self, &NSObject.AssociatedKeys.CancellablesKey, Wrapped(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif // os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
#endif // canImport(Combine)
