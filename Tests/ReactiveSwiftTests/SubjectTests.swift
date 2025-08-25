// ReactiveSwift
// SubjectTests.swift
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
import ReactiveSwift
import Testing

@Suite
struct SubjectTests {

    @Test
    func behavior() async {
        let subject = BehaviorSubject<Int>(initialValue: 3)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        subject.onNext(4)
        subject.onNext(5)
        subject.onCompleted()
        subject.onNext(6)
        #expect(await subscription.value == [3, 4, 5])
        let next = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        let t = await next.value
        #expect(t == [5])
    }

    @Test
    func behaviorWithNewValue() async {
        let subject = BehaviorSubject<Int>(initialValue: 3)
        subject.onNext(4)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        subject.onNext(5)
        subject.onNext(6)
        subject.onCompleted()
        subject.onNext(7)
        #expect(await subscription.value == [4, 5, 6])
        let next = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        #expect(await next.value == [6])
    }

    @Test
    func behaviorWithError() async {
        let subject = BehaviorSubject<Int>(initialValue: 3)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
            return vals
        }
        subject.onNext(4)
        subject.onNext(5)
        subject.onError(TestError())
        subject.onNext(6)
        #expect(await subscription.value == [3, 4, 5])
        let next = Task.immediate {
            do {
                for try await _ in subject {
                    Issue.record("Recieved an value after error")
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
        }
        await next.value
    }

    @Test
    func behaviorWithNewValueAndError() async {
        let subject = BehaviorSubject<Int>(initialValue: 3)
        subject.onNext(4)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
            return vals
        }
        subject.onNext(5)
        subject.onNext(6)
        subject.onError(TestError())
        subject.onNext(7)
        #expect(await subscription.value == [4, 5, 6])
        let next = Task.immediate {
            do {
                for try await _ in subject {
                    Issue.record("Recieved an value after error")
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
        }
        await next.value
    }

    @Test
    func publish() async {
        let subject = PublishSubject<Int>()
        subject.onNext(3)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        subject.onNext(4)
        subject.onNext(5)
        subject.onCompleted()
        #expect(await subscription.value == [4, 5])
        let next = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        #expect(await next.value == [])
    }

    @Test
    func publishWithError() async {
        let subject = PublishSubject<Int>()
        subject.onNext(3)
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
            return vals
        }
        subject.onNext(4)
        subject.onNext(5)
        subject.onError(TestError())
        #expect(await subscription.value == [4, 5])
        let next = Task.immediate {
            do {
                for try await _ in subject {
                    Issue.record("Recieved an value after error")
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
        }
        await next.value
    }

    @Test
    func replay() async {
        let subject = ReplaySubject<Int>(bufferSize: 3)
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3)
        subject.onNext(4)
        subject.onCompleted()
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
            } catch {
                Issue.record("Unexpected error")
            }
            return vals
        }
        #expect(await subscription.value == [2, 3, 4])
    }

    @Test
    func replayWithError() async {
        let subject = ReplaySubject<Int>(bufferSize: 3)
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3)
        subject.onNext(4)
        subject.onError(TestError())
        let subscription = Task.immediate {
            var vals = [Int]()
            do {
                for try await value in subject {
                    vals.append(value)
                }
                Issue.record("Expected an error, but didn't get one")
            } catch {
                #expect(error is TestError)
            }
            return vals
        }
        #expect(await subscription.value == [2, 3, 4])
    }

}

struct TestError: Error {
    init() {}
}
