// ReactiveSwift
// SubjectType.swift
//
// MIT License
//
// Copyright (c) 2025 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// A subject is a sequence that emits events to observers, until it either completes or errors.
public protocol SubjectType<Element>: AsyncSequence, Sendable where Element: Sendable, Failure == any Error {

    /// Send an event to observers
    /// - Parameter event: The event
    func on(_ event: SubjectEvent<Element>)

}

extension SubjectType {

    /// Send a value event to observers
    /// - Parameter value: The value to send
    public func onNext(_ value: Element) {
        on(.next(value))
    }

    /// Send a completion event to observers
    public func onCompleted() {
        on(.completed)
    }

    /// Send an error event to observers
    /// - Parameter error: The error
    public func onError(_ error: any Error) {
        on(.error(error))
    }

    /// Send a value event to observers
    public func onNext() where Element == Void {
        onNext(())
    }

}

/// A subject event
public enum SubjectEvent<Element>: Sendable where Element: Sendable {

    /// A value event
    case next(Element)

    /// A completion event
    case completed

    /// An error event
    case error(any Error)

}
