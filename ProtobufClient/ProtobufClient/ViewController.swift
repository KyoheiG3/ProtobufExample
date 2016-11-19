//
//  ViewController.swift
//  ProtobufClient
//
//  Created by Kyohei Ito on 2016/11/19.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftProtobuf

class ViewController: UIViewController {
    @IBOutlet weak var swiftJsonButton: UIButton!
    @IBOutlet weak var swiftProtobufButton: UIButton!
    @IBOutlet weak var goJsonButton: UIButton!
    @IBOutlet weak var goProtobufButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func getRequest(url: String) -> URLRequest {
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            return request
        }
        
        func data(request: URLRequest) -> Observable<Data> {
            return URLSession.shared.rx.data(request: request)
                .do(onNext: { data in
                    print(data)
                })
        }
        
        func libraryOfJson<T>(url: String) -> Observable<T> {
            var request = getRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return data(request: request)
                .map {
                    String(bytes: $0, encoding: .utf8) as! T
                }
        }
        
        func libraryOfData<T>(url: String) -> Observable<T> {
            var request = getRequest(url: url)
            request.setValue("application/protobuf", forHTTPHeaderField: "Accept")
            
            return data(request: request)
                .map {
                    try MyLibrary(protobuf: $0) as! T
                }
        }
        
        let observer = PublishSubject<CustomDebugStringConvertible>()
        observer
            .subscribe(onNext: { data in
                print(data)
            }, onError: { error in
                print(error)
            })
            .addDisposableTo(disposeBag)
        
        goJsonButton.rx.tap
            .flatMap {
                libraryOfJson(url: "http://localhost:8080/")
            }
            .bindTo(observer)
            .addDisposableTo(disposeBag)
        
        goProtobufButton.rx.tap
            .flatMap {
                libraryOfData(url: "http://localhost:8080/")
            }
            .bindTo(observer)
            .addDisposableTo(disposeBag)
        
        swiftJsonButton.rx.tap
            .flatMap {
                libraryOfJson(url: "http://localhost:8090/")
            }
            .bindTo(observer)
            .addDisposableTo(disposeBag)
        
        swiftProtobufButton.rx.tap
            .flatMap {
                libraryOfData(url: "http://localhost:8090/")
            }
            .bindTo(observer)
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
