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

#endif
