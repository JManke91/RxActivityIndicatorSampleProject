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

    let activityTracker = ActivityTracker()
    var loadingState: Driver<LoadingState>


    init() {
        self.loadingState = activityTracker.asDriver()
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

                .trackActivity(activityTracker)
        } else {
            return makeErrorRequest()
                .trackActivity(activityTracker)
        }
    }

    func observeCompletable() -> Completable {
        return makeSuccessRequestCompletable()
            .trackActivity(activityTracker)
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
            .trackActivity(activityTracker)
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
