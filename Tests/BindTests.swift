//
//  BindTests.swift
//  CombineExtTests
//
//  Created by Frank Schlegel on 02/12/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if !os(watchOS)
import XCTest
import Combine
import CombineExt

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class BindTests: XCTestCase {
    func testBind() {
        let subject = PassthroughSubject<String, Never>()
        let object = BindableObject()
        
        subject.bind(to: object) { object, value in
            object.setReferenceValue(value)
        }
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send("first")
        XCTAssertEqual(object.referenceValue, "first")
        
        subject.send("second")
        XCTAssertEqual(object.referenceValue, "second")
        
        subject.send("third")
        XCTAssertEqual(object.referenceValue, "third")
    }
    
    func testBindNSObject() {
        let subject = PassthroughSubject<String, Never>()
        let object = BindableNSObject()
        
        subject.bind(to: object) { object, value in
            object.setReferenceValue(value)
        }
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send("first")
        XCTAssertEqual(object.referenceValue, "first")
        
        subject.send("second")
        XCTAssertEqual(object.referenceValue, "second")
        
        subject.send("third")
        XCTAssertEqual(object.referenceValue, "third")
    }
    
    func testBindToVoidPublisher() {
        let subject = PassthroughSubject<Void, Never>()
        let object = BindableObject()
        
        subject.bind(to: object) { object in
            object.setReferenceValue("fired")
        }
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send(())
        XCTAssertEqual(object.referenceValue, "fired")
    }
    
    func testBindToVoidPublisherWithCompletion() {
        let subject = PassthroughSubject<Void, Never>()
        let object = BindableObject()
        var completed = false
        
        subject.bind(to: object,
                     receiveCompletion: { object, completion in completed = true },
                     receiveValue: { object in object.referenceValue = "fired" })
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send(())
        XCTAssertEqual(object.referenceValue, "fired")
        
        subject.send(completion: .finished)
        XCTAssertTrue(completed)
    }
    
    func testBindWithCompletion() {
        let subject = PassthroughSubject<String, Never>()
        let object = BindableObject()
        var completed = false
        
        subject.bind(to: object,
                     receiveCompletion: { object, completion in completed = true },
                     receiveValue: { object, value in object.referenceValue = value })
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send("first")
        XCTAssertEqual(object.referenceValue, "first")
        
        subject.send("second")
        XCTAssertEqual(object.referenceValue, "second")
        
        subject.send("third")
        XCTAssertEqual(object.referenceValue, "third")
        
        subject.send(completion: .finished)
        XCTAssertTrue(completed)
    }
    
    func testBindToKeyPath() {
        let subject = PassthroughSubject<String, Never>()
        let object = BindableObject()
        
        subject.bind(to: object, keyPath: \.referenceValue)
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send("first")
        XCTAssertEqual(object.referenceValue, "first")
        
        subject.send("second")
        XCTAssertEqual(object.referenceValue, "second")
        
        subject.send("third")
        XCTAssertEqual(object.referenceValue, "third")
    }
    
    func testBindToKeyPathNSObject() {
        let subject = PassthroughSubject<String, Never>()
        let object = BindableNSObject()
        
        subject.bind(to: object, keyPath: \.referenceValue)
        XCTAssertEqual(object.referenceValue, "not set")
        
        subject.send("first")
        XCTAssertEqual(object.referenceValue, "first")
        
        subject.send("second")
        XCTAssertEqual(object.referenceValue, "second")
        
        subject.send("third")
        XCTAssertEqual(object.referenceValue, "third")
    }
    
    func testDeallocation() {
        let subject = PassthroughSubject<String, Never>()
        var object: BindableObject! = BindableObject()
        var lastSetValue: String?
        
        subject.bind(to: object) { object, value in
            lastSetValue = value
        }
        
        subject.send("first")
        XCTAssertEqual(lastSetValue, "first")
        
        object = nil
        
        subject.send("second")
        XCTAssertEqual(lastSetValue, "first",
                       "The last set value should remain unchanged after deallocation")
    }
    
    func testDeallocationNSObject() {
        let subject = PassthroughSubject<String, Never>()
        var object: BindableNSObject! = BindableNSObject()
        var lastSetValue: String?
        
        subject.bind(to: object) { object, value in
            lastSetValue = value
        }
        
        subject.send("first")
        XCTAssertEqual(lastSetValue, "first")
        
        object = nil
        
        subject.send("second")
        XCTAssertEqual(lastSetValue, "first",
                       "The last set value should remain unchanged after deallocation")
    }

}

// MARK: - Private Helpers
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private class BindableObject: BindingTarget {
    var cancellables = Set<AnyCancellable>()
    
    var referenceValue: String = "not set"
    
    func setReferenceValue(_ newValue: String) {
        referenceValue = newValue
    }
}

private class BindableNSObject: NSObject {
    var referenceValue: String = "not set"
    
    func setReferenceValue(_ newValue: String) {
        referenceValue = newValue
    }
}
#endif
