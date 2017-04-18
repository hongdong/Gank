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

final class HomeViewController: UIViewController {
    
    let tableView = UITableView().then {
        $0.register(cellType: HomeTableViewCell.self)
        $0.estimatedRowHeight = 100
        $0.separatorStyle = .none
        $0.refreshControl = UIRefreshControl()
    }
    
    let homeVM = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

extension HomeViewController {
    
    // MARK: - Private Method
    
    fileprivate func setup() {
        
        do /** UI Config */ {
            
            title = "Gank"
            view.addSubview(tableView)
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(view)
            }
            
        }
        
        do /** Rx Config */ {
            
            // 刷新绑定
            tableView.refreshControl?.rx.controlEvent(.allEvents)
                .bind(to: homeVM.homeOutput.refreshCommand)
                .addDisposableTo(rx_disposeBag)
                        
            homeVM.homeOutput.section
                .drive(tableView.rx.items(dataSource: homeVM.homeOutput.dataSource))
                .addDisposableTo(rx_disposeBag)
            
            tableView.rx.setDelegate(self)
                .addDisposableTo(rx_disposeBag)
            
            homeVM.homeOutput.refreshTrigger
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
            
            homeVM.homeOutput.dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: HomeTableViewCell.self)
                cell.gankTitle?.text = item.desc
                cell.gankAuthor.text = item.who
                cell.gankTime.text = item.publishedAt.toString(format: "YYYY/MM/DD")
                return cell
            }
            
            
            //第一次手动发起请求
            homeVM.homeOutput.refreshCommand.onNext()

            
        }
        
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
    }
}
