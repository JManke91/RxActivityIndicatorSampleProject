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

public class ActivityIndicator : SharedSequenceConvertibleType {
    public func asSharedSequence() -> SharedSequence<DriverSharingStrategy, Element> {
        return sharedState
    }

    public typealias Element = LoadingState
    public typealias SharingStrategy = DriverSharingStrategy

    private let lock = NSRecursiveLock()
    private let loadingStateRelay = BehaviorRelay(value: LoadingState.initial)
    private let sharedState: SharedSequence<SharingStrategy, LoadingState>

    public init() {
        sharedState = loadingStateRelay.asDriver()
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendError()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: sendLoading)
    }

    fileprivate func trackActivityOfSingle<O: PrimitiveSequenceType>(_ source: O) -> Single<O.Element> {
        return source.primitiveSequence.asObservable().take(1).asSingle()
            .do(onSuccess: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendError()
            }, onSubscribe: {
                self.sendLoading()
            })
    }

    fileprivate func trackActivityOfCompletable<O: PrimitiveSequenceType>(_ source: O) -> Completable {
        return source.primitiveSequence.asObservable().take(1).ignoreElements()
            .do(onError: { _ in
                self.sendError()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: {
                self.sendLoading()
            })
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

    private func sendStopLoading() {
        lock.lock()
        loadingStateRelay.accept(LoadingState.success)
        lock.unlock()
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Single<Element> {
        return activityIndicator.trackActivityOfSingle(self)
    }
}

extension PrimitiveSequence where Trait == CompletableTrait {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Completable {
        return activityIndicator.trackActivityOfCompletable(self)
    }
}


