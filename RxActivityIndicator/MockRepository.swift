//
//  MockRepository.swift
//  RxActivityIndicator
//
//  Created by Julian Manke on 30.07.19.
//  Copyright © 2019 Julian Manke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MockRepository {

    // NEW
    let activityIndicator = ActivityIndicator()
    var loadingState: Driver<LoadingState>

    // OLD
    var oldLoadingState = PublishSubject<LoadingState>()

    init() {
        // NEW
        self.loadingState = activityIndicator.asDriver()
    }

    func oldImplementationLoadingState() -> Driver<LoadingState> {
        return oldLoadingState.asDriver(onErrorJustReturn: LoadingState.error)
    }

    func newImplementationLoadingState() -> Driver<LoadingState> {
        return loadingState.asDriver(onErrorJustReturn: LoadingState.error)
    }

    private func makeSuccessRequest() -> Observable<Bool> {
        return Observable.create({ (observable) in
            // Create delay
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                observable.onNext(true)
            })
            return Disposables.create()
        })
    }

    private func makeErrorRequest() -> Observable<Bool> {
        return Observable.create({ (observable) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                observable.onError(CustomError.requestFailure)
            })
            return Disposables.create()
        })
    }


    func observeProperty(for expectedRequestResult: ExpectedRequestResult) -> Observable<Bool> {
        if expectedRequestResult == .success {
            return makeSuccessRequest()
//                .do(onNext: { (_) in
//                    self.oldLoadingState.onNext(LoadingState.success)
//                }, onError: { (error) in
//                    self.oldLoadingState.onNext(LoadingState.error)
//                }, onSubscribe: {
//                    self.oldLoadingState.onNext(LoadingState.loading)
//                })
                        .trackActivity(activityIndicator) // Replace this
        } else {
            return makeErrorRequest()
//                .do(onNext: { (_) in
//                    self.oldLoadingState.onNext(LoadingState.success)
//                }, onError: { (error) in
//                    self.oldLoadingState.onNext(LoadingState.error)
//                }, onSubscribe: {
//                    self.oldLoadingState.onNext(LoadingState.loading)
//                })
            .trackActivity(activityIndicator)
        }
    }

    func observeCompletable() -> Completable {
        return makeSuccessRequestCompletable()
            .trackActivity(activityIndicator)
    }

    private func makeSuccessRequestCompletable() -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    func observeSingle() -> Single<Bool> {
        return makeSuccessRequestSingle()
            .trackActivity(activityIndicator)
    }

    private func makeSuccessRequestSingle() -> Single<Bool> {
        return Single.create { single in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                single(.success(true))
            }
            return Disposables.create()
        }
    }
}

enum ExpectedRequestResult {
    case success
    case error
}

enum CustomError: Error {
    case requestFailure
}
