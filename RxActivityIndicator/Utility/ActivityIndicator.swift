//
//  ActivityIndicator.swift
//  RxActivityIndicator
//
//  Created by Julian Manke on 30.07.19.
//  Copyright © 2019 Julian Manke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ActivityTracker: SharedSequenceConvertibleType {
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Element> {
        return sharedState
    }

    public let loadingStateRelay = BehaviorRelay(value: LoadingState.initial)
    public typealias Element = LoadingState
    public typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private let sharedState: SharedSequence<SharingStrategy, LoadingState>

    public init() {
        sharedState = loadingStateRelay
            .asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { [weak self] _ in
                self?.sendSuccess()
                }, onError: { [weak self] _ in
                    self?.sendError()
                }, onSubscribe: sendLoading)
    }

    private func sendLoading() {
        lock.lock()
        loadingStateRelay.accept(LoadingState.loading)
        lock.unlock()
    }

    private func sendError() {
        lock.lock()
        loadingStateRelay.accept(LoadingState.error)
        lock.unlock()
    }

    private func sendSuccess() {
        lock.lock()
        loadingStateRelay.accept(LoadingState.success)
        lock.unlock()
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityTracker) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}


