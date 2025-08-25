// ReactiveSwift
// BehaviorSubject.swift
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

import Foundation
import Synchronization

public final class BehaviorSubject<Element>: SubjectType where Element: Sendable {

    // MARK: - Initializers

    public init(
        initialValue: Element
    ) {
        value = .init(initialValue)
    }

    // MARK: - SubjectType

    public func on(_ event: SubjectEvent<Element>) {
        switch event {
        case let .next(value):
            send(value)
        case let .error(error):
            finish(throwing: error)
        case .completed:
            finish(throwing: nil)
        }
    }

    // MARK: - AsyncSequence

    public func makeAsyncIterator() -> some AsyncIteratorProtocol<Element, any Error> {
        AsyncThrowingStream { continuation in
            guard !Task.isCancelled else {
                continuation.finish()
                return
            }
            status.withLock { status in
                switch status {
                case let .completed(error):
                    if let error {
                        continuation.finish(throwing: error)
                    } else {
                        value.withLock { value in
                            _ = continuation.yield(value)
                        }
                        continuation.finish(throwing: error)
                    }
                case .open:
                    let id = UUID()
                    observers.withLock { observers in
                        observers[id] = continuation
                    }
                    value.withLock { value in
                        _ = continuation.yield(value)
                    }
                }

            }
        }
        .makeAsyncIterator()
    }

    // MARK: - Private

    private enum Status {
        case open
        case completed((any Error)?)
    }

    private let observers = Mutex<[UUID: AsyncThrowingStream<Element, any Error>.Continuation]>([:])
    private let value: Mutex<Element>
    private let status = Mutex<Status>(.open)

    private func send(_ newValue: Element) {
        status.withLock { status in
            switch status {
            case .open:
                value.withLock { value in
                    value = newValue
                }
                observers.withLock { observers in
                    var expired = [UUID]()
                    for (id, observer) in observers {
                        if case .terminated = observer.yield(newValue) {
                            expired.append(id)
                        }
                    }
                    for id in expired {
                        observers[id] = nil
                    }
                }
            case .completed:
                return
            }
        }
    }

    private func finish(throwing error: (any Error)?) {
        status.withLock { status in
            status = .completed(error)
        }
        observers.withLock { observers in
            for observer in observers.values {
                observer.finish(throwing: error)
            }
            observers = [:]
        }
    }

}
