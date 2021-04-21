//
//  ViewController.swift
//  RxActivityIndicator
//
//  Created by Julian Manke on 30.07.19.
//  Copyright © 2019 Julian Manke. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var makeSuccessRequestButton: UIButton!
    @IBOutlet weak var makeErrorRequestButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let repository = MockRepository()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        styleButtons()

        repository.newImplementationLoadingState()
            .drive(onNext: { loadingState in
                switch loadingState {
                case .loading:
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                case .success:
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.showToast(message: "Successful request", toastColor: .green)
                case .error:
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.showToast(message: "An error occured!", toastColor: .red)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }

    private func styleButtons() {
        makeSuccessRequestButton.layer.cornerRadius = 5
        makeSuccessRequestButton.layer.borderWidth = 1
        makeSuccessRequestButton.layer.borderColor = UIColor.black.cgColor

        makeErrorRequestButton.layer.cornerRadius = 5
        makeErrorRequestButton.layer.borderWidth = 1
        makeErrorRequestButton.layer.borderColor = UIColor.black.cgColor
    }

    @IBAction func errorButtonPressed() {
        repository.observeProperty(for: ExpectedRequestResult.error).subscribe(onNext: { (property) in
        }, onError: { error in
        })
        .disposed(by: disposeBag)
    }

    @IBAction func successButtonPressed() {
        repository.observeProperty(for: ExpectedRequestResult.success)
            .subscribe()
            .disposed(by: disposeBag)
    }

    func showToast(message : String, toastColor: UIColor) {

        let width: CGFloat = 200

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - width / 2, y: self.view.frame.size.height-100, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.backgroundColor = toastColor
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

}

