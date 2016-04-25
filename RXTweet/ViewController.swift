//
//  ViewController.swift
//  RXTweet
//
//  Created by Anak Mirasing on 11/25/15.
//  Copyright © 2015 VINTX. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var disposeBag = DisposeBag()
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: SETUP
    func setup() {
        
        // TableView
        tableView.registerNib(UINib(nibName: UserCell.identifier,bundle: nil), forCellReuseIdentifier: UserCell.identifier)
        
        // Stream
        let refreshClickStream = refreshButton.rx_tap.asObservable()
        
        let requestStream = refreshClickStream
            .startWith(Void())
            .map { (_) -> Void in
                self.showLoadingHUD()
            }
            .map { (_) -> ApiService in
                return .GetUsersWithRandomOffset
            }
        
        let responseStream = requestStream.flatMap { (service: ApiService) -> Observable<AnyObject> in
            return GitProvider.request(service).mapJSON()
            }
        
        responseStream
        .showErrorHUD()
        .map { (responseJSON) -> [User] in
            
            self.hideLoadingHUD()
            
            guard let usersArray = Mapper<User>().mapArray(responseJSON) else { return [] }
            return usersArray
        }
        .bindTo(tableView.rx_itemsWithCellIdentifier(UserCell.identifier, cellType: UserCell.self)) { (row: Int, user: User, cell: UserCell) in
                cell.textLabel?.text = user.username
        }.addDisposableTo(disposeBag)
        
        
        // TableView Selected
        let modelSelectedStream = tableView.rx_modelSelected(User)
        let cellSelectedStream = tableView.rx_itemSelected
        
        Observable.zip(modelSelectedStream, cellSelectedStream) { (user, indexPath) -> () in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            print(user.username)
            print(user.repos_url)
            print(user.html_url)
        }
        .subscribe()
        .addDisposableTo(disposeBag)
        
    }
    
}

