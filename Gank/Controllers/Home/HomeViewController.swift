//
//  HomeViewController.swift
//  Gank
//
//  Created by Maru on 2016/12/1.
//  Copyright © 2016年 Maru. All rights reserved.
//

import UIKit
import SwiftWebVC
import EZSwiftExtensions
import Then
import SnapKit
import Reusable
import RxSwift
import RxCocoa
import Kingfisher
import NoticeBar
import PullToRefresh

final class HomeViewController: UIViewController {
    
    let tableView = UITableView().then {
        $0.register(cellType: HomeTableViewCell.self)
    }
    
    let refreshControl = PullToRefresh()
    
    let homeVM = HomeViewModel()
        
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeViewController {
    
    // MARK: - Private Method
    
    fileprivate func setup() {
        
        do /** UI Config */ {
            
            title = "Gank"
            
            tableView.estimatedRowHeight = 100
            tableView.separatorStyle = .none
            tableView.refreshControl = UIRefreshControl()
            
            view.addSubview(tableView)
            
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(view)
            }
            
        }
        
        do /** Rx Config */ {
            
            // Input
            let inputStuff  = HomeViewModel.HomeInput()
            
            // Output
            let outputStuff = homeVM.transform(input: inputStuff)
        
            // DataBinding
            tableView.refreshControl?.rx.controlEvent(.allEvents)
                .flatMap({ inputStuff.category.asObservable() })
                .bindTo(outputStuff.refreshCommand)
                .addDisposableTo(rx_disposeBag)
            
            NotificationCenter.default.rx.notification(Notification.Name.category)
                .map({ (notification) -> Int in
                    let indexPath = (notification.object as? IndexPath) ?? IndexPath(item: 0, section: 0)
                    return indexPath.row
                })
                .bindTo(inputStuff.category)
                .addDisposableTo(rx_disposeBag)
            

            NotificationCenter.default.rx.notification(Notification.Name.category)
                .map({ (notification) -> Int in
                    let indexPath = (notification.object as? IndexPath) ?? IndexPath(item: 0, section: 0)
                    return indexPath.row
                })
                .observeOn(MainScheduler.asyncInstance)
                .do(onNext: { (idx) in

                }, onError: nil, onCompleted: nil, onSubscribe:nil,onDispose: nil)
                .bindTo(outputStuff.refreshCommand)
                .addDisposableTo(rx_disposeBag)
                        
            outputStuff.section
                .drive(tableView.rx.items(dataSource: outputStuff.dataSource))
                .addDisposableTo(rx_disposeBag)
            
            tableView.rx.setDelegate(self)
                .addDisposableTo(rx_disposeBag)
            
            outputStuff.refreshTrigger
                .observeOn(MainScheduler.instance)
                .subscribe { [unowned self] (event) in
                    self.tableView.refreshControl?.endRefreshing()
                    switch event {
                    case .error(_):
                        NoticeBar(title: "Network Disconnect!", defaultType: .error).show(duration: 2.0, completed: nil)
                        break
                    case .next(_):
                        self.tableView.reloadData()
                        break
                    default:
                        break
                    }
                }
                .addDisposableTo(rx_disposeBag)
            
            // Configure
            
            outputStuff.dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
                cell.gankTitle?.text = item.desc
                cell.gankAuthor.text = item.who
                cell.gankTime.text = item.publishedAt.toString(format: "YYYY/MM/DD")
                return cell
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name.category, object: IndexPath(row: 0, section: 0))
        
    }
    
}

extension HomeViewController {
    
    // MARK: - Private Methpd
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webActivity = BrowserWebViewController(url: homeVM.itemURLs.value[indexPath.row])
        navigationController?.pushViewController(webActivity, animated: true)
    }
}
