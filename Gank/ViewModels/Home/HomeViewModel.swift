//
//  HomeViewModel.swift
//  Gank
//
//  Created by Maru on 2016/12/7.
//  Copyright © 2016年 Maru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Moya
import Then

struct HomeSectionModel: SectionModelType {
    
    typealias Item = Brick
    
    var items: [Item]
    
    init(items:[Item]) {
        self.items = items
    }
    
    init(original: HomeSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
}

final class HomeViewModel: NSObject,ViewModelType {
    
    //protocol泛型
    typealias Input  = HomeInput
    typealias Output = HomeOutput
    
    // Input结构体
    struct HomeInput {

    }
    
    // Output结构体
    struct HomeOutput {
        
        let section: Driver<[HomeSectionModel]>
        let refreshCommand = PublishSubject<Void>()
        let refreshTrigger = PublishSubject<Void>()
        let dataSource = RxTableViewSectionedReloadDataSource<HomeSectionModel>()
        
        init(homeSection: Driver<[HomeSectionModel]>) {
            section = homeSection
        }
    }
    
    //=====属性======//
    
    let homeInput = HomeInput()
    
    lazy var homeOutput:HomeOutput = {
        [weak self] () -> HomeOutput in
        let tempWebView = self?.transform(input: (self?.homeInput)!)
        return tempWebView!
    }()

    // Private Stuff
    fileprivate let _bricks = Variable<[Brick]>([])
    
    //===========//

    
    /// Tansform Action for DataBinding
    func transform(input: HomeViewModel.Input) -> HomeViewModel.Output {
        
        let section = _bricks.asObservable().map({ (bricks:[Brick]) -> [HomeSectionModel] in
            return [HomeSectionModel(items: bricks)]
        })
        .asDriver(onErrorJustReturn: [])
        
        let output = Output(homeSection: section)
        
        output.refreshCommand
            .flatMapLatest { gankApi.request(.data(type: "0", size: 20, index: 0)) }
            .subscribe({ [weak self] (event) in
                output.refreshTrigger.onNext()
                switch event {
                case let .next(response):
                    do {
                        let data = try response.mapArray(Brick.self)
                        self?._bricks.value = data
                    }catch {
                        self?._bricks.value = []
                    }
                    break
                case let .error(error):
                    output.refreshTrigger.onError(error);
                    break
                default:
                    break
                }
            })
            .addDisposableTo(rx_disposeBag)
        
        return output
    }
    

    
}


