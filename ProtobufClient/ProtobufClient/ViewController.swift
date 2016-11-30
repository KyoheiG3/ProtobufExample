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
import Protobuf

private let stabJSON = "{\"id\":\"20\",\"name\":\"Swift\",\"books\":[{\"id\":\"10\",\"title\":\"Welcome to Swift\",\"author\":\"Apple Inc.\"}],\"keys\":{\"route\":\"66\"}}"

class TableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var acceptLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var byteLabel: UILabel!
    
    fileprivate let requests = [
        RequestInfo(api: .go,       type: .json,        path: "/"),
        RequestInfo(api: .go,       type: .protobuf,    path: "/"),
        RequestInfo(api: .go,       type: .protobuf,    path: "/stab"),
        RequestInfo(api: .swift,    type: .json,        path: "/"),
        RequestInfo(api: .swift,    type: .protobuf,    path: "/"),
        RequestInfo(api: .swift,    type: .json,        path: "/protobuf"),
        RequestInfo(api: .swift,    type: .protobuf,    path: "/json"),
        RequestInfo(api: .swift,    type: .protobuf,    path: "/stab"),
    ]
    
    fileprivate let disposeBag = DisposeBag()
    
    func data<T>(request: URLRequest) -> Observable<T> {
        guard request.url?.path != "/stab" else {
            self.typeLabel.text = "-"
            self.byteLabel.text = "-"
            self.typeLabel.text = "-"
            
            // return stab data.
            return .just(try! MyLibrary(json: stabJSON) as! T)
        }
        
        return URLSession.shared.rx.response(request: request)
            .observeOn(MainScheduler.instance)
            .map { [unowned self] (response, data) -> T in
                if 200 ..< 300 ~= response.statusCode {
                    let contentType = response.allHeaderFields["Content-Type"] as? String
                    let accept = request.allHTTPHeaderFields?["Accept"]
                    
                    self.byteLabel.text = "\(data)"
                    self.typeLabel.text = contentType
                    
                    // This examples return serialized json string if json string needed. also return deserialized protobuf object if protobuf needed.
                    if let type = contentType, type == "application/protobuf" {
                        let library = try MyLibrary(protobuf: data)
                        
                        if accept == "application/json" {
                            return try library.serializeJSON() as! T
                        } else {
                            return library as! T
                        }
                    } else {
                        let json = String(bytes: data, encoding: .utf8)
                        
                        if accept == "application/protobuf" {
                            return try MyLibrary(json: json!) as! T
                        } else {
                            return json as! T
                        }
                    }
                }
                else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
            }
            .do(onError: { [unowned self] _ in
                self.byteLabel.text = "-"
                self.typeLabel.text = "-"
            })
            .catchError { error in
                .just(error as! T)
            }
    }
    
    func getRequest(url: String) -> URLRequest {
        let url = URL(string: url)!
        pathLabel.text = ":\(url.port!)\(url.path)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let info = requests[indexPath.row]
        cell.textLabel?.text = "\(info.api.port)\(info.path)"
        cell.detailTextLabel?.text = info.type.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let info = requests[indexPath.row]
        acceptLabel.text = info.type.description
        
        var request = getRequest(url: info.url)
        request.setValue(info.type.description, forHTTPHeaderField: "Accept")
        
        data(request: request)
            .single()
            .map { (data: CustomDebugStringConvertible) in data.debugDescription }
            .bindTo(dataLabel.rx.text)
            .addDisposableTo(disposeBag)
    }
}
