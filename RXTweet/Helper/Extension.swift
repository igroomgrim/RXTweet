//
//  Extension.swift
//  RXTweet
//
//  Created by Anak Mirasing on 4/25/16.
//  Copyright © 2016 VINTX. All rights reserved.
//

import Foundation
import SVProgressHUD
import RxSwift
import Moya

extension Observable {
    func showErrorHUD() -> Observable<Element> {
        return self.doOn { event in
            switch event {
            case .Error(let e):
                // Unwrap underlying error
                guard let error = e as? Moya.Error else { throw e }
                SVProgressHUD.showErrorWithStatus("Error \(error)")
                
            default: break
            }
        }
    }
}

extension ViewController {
    
    func showLoadingHUD() {
        SVProgressHUD.show()
    }
    
    func hideLoadingHUD() {
        SVProgressHUD.dismiss()
    }
}