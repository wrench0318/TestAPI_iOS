//
//  UsersModel.swift
//  TestAPI
//
//  Created by 土橋正晴 on 2020/01/06.
//  Copyright © 2020 m.dobashi. All rights reserved.
//


import Unbox
import Alamofire


class UsersModel: Unboxable {
    
    // MARK: Properties
    
    /// リクエストするURL
    private static let url = URL(string: "http://localhost:3000/api/v1/users")
    
    /// ID
    let id: String?
    
    /// 名前
    let name: String?
    
    /// テキスト
    let text: String?
        
    
    
    
    // MARK: Init
    
    required init(unboxer: Unboxer) throws {
        id = try? unboxer.unbox(key: "id")
        name = try? unboxer.unbox(key: "name")
        text = try? unboxer.unbox(key: "text")
    }
    
    
    
    
    // MARK: Class Func
    
    // JSONをUsersModelに格納できるよう変換
    class func unboxDictionary(dictionary: Any) -> UsersModel {
        return  try! unbox(dictionary: dictionary as! UnboxableDictionary)
    }
    
    
    
    
    // MARK: Request
    
    /// 全ユーザー名を取得する
    /// - Parameters:
    ///   - viewController: 呼び出し元のVIewController
    ///   - callBask: getしたものを返す
    class func fetchUsers(viewController: UIViewController, callBask: @escaping([UsersModel])->()) {
        
        var usersModel = [UsersModel]()
        
        Alamofire.request(url!, method: .get, headers: .none).response { response in
          
            guard response.error == nil else {
                AlertManager().alertAction(viewController: viewController, title: "接続に失敗しました", message: "再度接続しますか?", handler1: { action in
                    self.fetchUsers(viewController: viewController) { _ in }
                    
                }) { _ in }
                return
            }
        
            
            do {
                let json = try JSONSerialization.jsonObject(with: response.data!, options: .fragmentsAllowed) as! [Any]
                usersModel = json.map { user -> UsersModel in
                    
                    print("user = \(user)")
                    
                    
                    return UsersModel.unboxDictionary(dictionary: user)
                }
            } catch {
                AlertManager().alertAction(viewController: viewController, title: "Error", message: "", handler: { (action) in
                    return
                })
                return
            }
            
            responsePrint(response)
            
            callBask(usersModel)
        }
        
    }
    
    
    
    
    
    
    /// ユーザー名を作成する
    /// - Parameters:
    ///   - viewController: 呼び出し元のVIewController
    ///   - name: 登録する名前
    ///   - text: 登録するテキスト
    class func postRequest(viewController: UIViewController, name: String, text: String) {
        
        let params:[String:Any] = [
            "user":["name":name, "text":text]
        ]
        
        
        Alamofire.request(url!, method: .post, parameters: params).response { response in
            
            guard response.error == nil else {
                AlertManager().alertAction(viewController: viewController, title: "接続に失敗しました", message: "再度接続しますか?", handler1: { action in
                    self.postRequest(viewController: viewController, name: name, text: text)
                    
                }) { _ in }
                return
            }
            
            
            AlertManager().alertAction(viewController: viewController,
                                       title: "", message: "ユーザを保存しました") { _ in
                                        viewController.dismiss(animated: true) {
                                            NotificationCenter.default.post(name: Notification.Name(ViewUpdate), object: nil)
                                        }
            }
            responsePrint(response)
            
        }
        
    }

    
    
    /// ユーザ名を更新する
    /// - Parameters:
    ///   - viewController: 呼び出し元のVIewController
    ///   - id: ID
    ///   - name: 変更する名前
    ///   - text: 変更するテキスト
    class func putRequest(viewController: UIViewController, id: String?, name: String, text: String) {
        
        guard let _id = id else {
            print("idの取得に失敗")
            return
        }
        
        let acccesURL = URL(string: String("\(url!)/\(_id)"))
        
        let params:[String:Any] = [
            "user":["name":name, "text":text]
        ]
        
        
        
        Alamofire.request(acccesURL!, method: .put, parameters: params).response { response in
            
            guard response.error == nil else {
                AlertManager().alertAction(viewController: viewController, title: "接続に失敗しました", message: "再度接続しますか?", handler1: { action in
                    self.putRequest(viewController: viewController, id: _id, name: name, text: text)
                    
                }) { _ in }
                return
            }
            
            
            AlertManager().alertAction(viewController: viewController,
                                       title: "", message: "ユーザを更新しました") { _ in
                                        viewController.dismiss(animated: true) {
                                            NotificationCenter.default.post(name: Notification.Name(ViewUpdate), object: nil)
                                        }
            }
            responsePrint(response)
            
        }
    }
    
    
    
    
    
    // MARK: Print
    
    fileprivate class func responsePrint(_ response:DefaultDataResponse?) {
        
        #if DEBUG
        if let _response = response {
            print(" --------- \(String(describing: _response.response!.url!)) \(String(describing: _response.request!.httpMethod!)) response Start --------- ")
            print(_response.response!)
            print(" --------- \(String(describing: _response.response!.url!)) \(String(describing: _response.request!.httpMethod!)) response End --------- ")
        } else {
            print("NO Response")
        }
        #endif
        
    }
    
    
    
    
    
    
    
}


