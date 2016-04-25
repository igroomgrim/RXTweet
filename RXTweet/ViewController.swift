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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        tableView.delegate = self
        tableView.dataSource = self
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
            .subscribeNext { responseJSON in
                
                guard let usersArray = Mapper<User>().mapArray(responseJSON) else { return }
                self.users = usersArray
                
                self.tableView.reloadData()
                self.hideLoadingHUD()
            }.addDisposableTo(disposeBag)
        
        // Example
        /*
        responseStream
            .subscribe { event in
            switch event {
                case .Next(let responseJson):
                    print(responseJson)
                break
                case .Error(let error):
                    print("Error : \(error)")
                break
                case .Completed:
                    print("responseStream : Complete")
                break
            }
        }.addDisposableTo(disposeBag)
        */
        
    }
    
    // MARK: TableView DataSource & Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UserCell.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(UserCell.identifier, forIndexPath: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let user = users[indexPath.row]
        print(user.username)
        print(user.html_url)
        print(user.repos_url)
    }



}

