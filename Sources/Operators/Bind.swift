//
//  Bind.swift
//  CombineExt
//
//  Created by Frank Schlegel on 30/11/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//
//  The concept of Bindings is inspired by and the implementation
//  heavily borrowed from ReactiveKit by Srđan Rašić. Thanks!
//  (See https://github.com/DeclarativeHub/ReactiveKit#bindings)
//

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    /// "Binds" the publisher to the target, i.e. the target receives values and completion events
    /// and ensures that the subscription is cancelled when the target is deallocated.
    /// - Parameters:
    ///   - target: The target object to bind the publisher to.
    ///   - receiveCompletion: The closure to execute on completion. The first parameter is the binding target.
    ///   - receiveValue: The closure to execute on receipt of a value. The first parameter is the binding target.
    func bind<Target: BindingTarget>(to target: Target, receiveCompletion: @escaping (Target, Subscribers.Completion<Self.Failure>) -> Void, receiveValue: @escaping (Target, Self.Output) -> Void) {
        sink(receiveCompletion: { [weak target] completion in
            if let target = target { receiveCompletion(target, completion) }
        }, receiveValue: { [weak target] element in
            if let target = target { receiveValue(target, element) }
        }).store(in: &target.cancellables)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Self.Failure == Never {
    /// "Binds" the publisher to the target, i.e. the target receives values
    /// and ensures that the subscription is cancelled when the target is deallocated.
    /// - Parameters:
    ///   - target: The target object to bind the publisher to.
    ///   - receiveValue: The closure to execute on receipt of a value. The first parameter is the binding target.
    func bind<Target: BindingTarget>(to target: Target, receiveValue: @escaping (Target, Self.Output) -> Void) {
        sink { [weak target] element in
            if let target = target { receiveValue(target, element) }
        }.store(in: &target.cancellables)
    }

    /// "Binds" the publisher to the target and assigns new values to a property.
    /// The subscription created this way is cancelled when the target is deallocated.
    ///
    /// Using this method will _not_ accidentally create any reference cycle between
    /// the subscription and the target, in contrast to Combine's `assign(to:on:)`.
    /// See [this forum discussion](https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546)
    /// - Parameters:
    ///   - target: The object that contains the property. The subscriber assigns the object's property every time it receives a new value.
    ///   - keyPath: A key path that indicates the property to assign.
    func bind<Target: BindingTarget>(to target: Target, keyPath: ReferenceWritableKeyPath<Target, Self.Output>) {
        sink { [weak target] element in
            target?[keyPath: keyPath] = element
        }.store(in: &target.cancellables)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Self.Output == Void {
    /// "Binds" the publisher to the target, i.e. the target receives values and completion events
    /// and ensures that the subscription is cancelled when the target is deallocated.
    /// - Parameters:
    ///   - target: The target object to bind the publisher to.
    ///   - receiveCompletion: The closure to execute on completion. The first parameter is the binding target.
    ///   - receiveValue: The closure to execute on receipt of a value. The parameter is the binding target.
    func bind<Target: BindingTarget>(to target: Target, receiveCompletion: @escaping (Target, Subscribers.Completion<Self.Failure>) -> Void, receiveValue: @escaping (Target) -> Void) {
        sink(receiveCompletion: { [weak target] completion in
            if let target = target { receiveCompletion(target, completion) }
        }, receiveValue: { [weak target] in
            if let target = target { receiveValue(target) }
        }).store(in: &target.cancellables)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Self.Output == Void, Self.Failure == Never {
    /// "Binds" the publisher to the target, i.e. the target receives values events
    /// and ensures that the subscription is cancelled when the target is deallocated.
    /// - Parameters:
    ///   - target: The target object to bind the publisher to.
    ///   - receiveValue: The closure to execute on receipt of a value. The parameter is the binding target.
    func bind<Target: BindingTarget>(to target: Target, receiveValue: @escaping (Target) -> Void) {
        sink { [weak target] in
            if let target = target { receiveValue(target) }
        }.store(in: &target.cancellables)
    }
}
#endif
