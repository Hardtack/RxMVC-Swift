//
//  GitHubSearchViewController.swift
//  RxMVC
//
//  Asynchronous networking example.
//  Searchs repositories from GitHub and renders to tableview.
//  And it is also example of dividing M-V-C into multiple files.
//
//  Copyright © 2016년 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxMVC

class GitHubSearchViewController: UIViewController, GitHubSearchControllerDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = GitHubSearchModel()
        let view = GitHubSearchView(searchTextField: searchTextField, tableView: tableView)
        let controller = GitHubSearchController(delegate: self)
        combineModel(model, withView: view, controller: controller).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Controller delegate functions
    
    func openURL(url: URL) {
        UIApplication.shared.openURL(url)
    }
}
