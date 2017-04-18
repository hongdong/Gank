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

struct HomeSection {
    
    var items: [Brick]
}

extension HomeSection: SectionModelType {
    
    typealias Item = Brick
    
    init(original: HomeSection, items: [Brick]) {
        self = original
        self.items = items
    }
}

final class HomeViewModel: NSObject,ViewModelType {
    
    override init() {
        
        super.init()
        
        _bricks.asObservable().map { (bricks) -> [URL] in
            return bricks.map({ (brick) -> URL in
                return URL(string: brick.url)!
            })
            }.subscribe(onNext: { [weak self] (urls) in
                self?.itemURLs.value = urls
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    typealias Input  = HomeInput
    typealias Output = HomeOutput
    
    // Inputs
    struct HomeInput {
        let category = Variable<Int>(0)
    }
    
    // Output
    struct HomeOutput {
        
        let section: Driver<[HomeSection]>
        let refreshCommand = PublishSubject<Int>()
        let refreshTrigger = PublishSubject<Void>()
        let dataSource = RxTableViewSectionedReloadDataSource<HomeSection>()
        
        init(homeSection: Driver<[HomeSection]>) {
            section = homeSection
        }
    }
    
    let homeInput = HomeInput()
    
    lazy var homeOutput:HomeOutput = {
        [weak self] () -> HomeOutput in
        let tempWebView = self?.transform(input: (self?.homeInput)!)
        return tempWebView!
    }()

    // Public  Stuff
    var itemURLs = Variable<[URL]>([])
    // Private Stuff
    fileprivate let _bricks = Variable<[Brick]>([])
    
    /// Tansform Action for DataBinding
    func transform(input: HomeViewModel.Input) -> HomeViewModel.Output {
        
        let section = _bricks.asObservable().map({ (bricks:[Brick]) -> [HomeSection] in
            return [HomeSection(items: bricks)]
        })
        .asDriver(onErrorJustReturn: [])
        
        let output = Output(homeSection: section)
        
        output.refreshCommand
            .flatMapLatest { gankApi.request(GankAPI.data(type: GankAPI.GankCategory.mapCategory(with: $0), size: 20, index: 0)) }
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
        
        input.category
        .asObservable()
        .bind(to: output.refreshCommand)
        .addDisposableTo(rx_disposeBag)
        
        return output
    }
    

    
}


