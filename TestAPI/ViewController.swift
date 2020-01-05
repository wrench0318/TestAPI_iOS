//
//  ViewController.swift
//  TestAPI
//
//  Created by 土橋正晴 on 2020/01/03.
//  Copyright © 2020 m.dobashi. All rights reserved.
//

import UIKit

/// リクエストするURL
let url = URL(string: "http://localhost:3000/api/v1/users")

/// iOS13以降でモーダルを閉じた時にViewWillAppearを呼ぶ
let ViewUpdate: String = "viewUpdate"





class ViewController: UITableViewController {

    
    
    /// テーブルビューを上からスワイプしたとき
    let refreshCtr = UIRefreshControl()
    
    
    /// ユーザー名を格納
    var usersModel: [[String: Any]]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarAction))
        NotificationCenter.default.addObserver(self, selector: #selector(callViewWillAppear(notification:)), name: NSNotification.Name(rawValue: ViewUpdate), object: nil)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshCtr
        refreshCtr.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getModel()
    }
    
    
    
    @objc override func rightBarAction() {
        let navigationController = UINavigationController(rootViewController: RegisterViewController())
        present(navigationController, animated: true)
    }
    
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = usersModel?[indexPath.row]["name"] as? String
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersModel == nil {
            return 1
        }
        
        return usersModel!.count
    }
    
    
    
    @objc func refresh(sender: UIRefreshControl) {
        getModel()
        sender.endRefreshing()
    }
    
    
    
    
    
    // MARK: Request
    
    /// 全ユーザー名を取得する
    func getModel() {
        
        let task: URLSessionTask = URLSession.shared.dataTask(with: url!) { data, response, error in

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as! [Any]
                self.usersModel = json.map { (user) -> [String: Any] in
                    print(user)
                    return user as! [String: Any]
                    
                }
            } catch {
                AlertManager().alertAction(viewController: self, title: "Error", message: error as! String, handler: { (action) in
                    return
                })
                return
            }
            
        }
        task.resume()
        
        
    }
    
    
    
    
    
    /// ユーザ名を更新する
    func putRequest(at row: Int) {
        
        let acccesURL = URL(string: String("\(url!)/\((String(row + 1)))"))
           var request = URLRequest(url: acccesURL!)
           request.httpMethod = "PUT"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           
           let params:[String:Any] = [
               "user":["name":"更新名"]
               
           ]
           
           
           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
               let task:URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                   print("data")
                   print(data!)
                   print("respnse")
                   print(response!)
                   
               })
               task.resume()
           } catch {
               print("エラー")
           }
       }

    
    @objc func callViewWillAppear(notification: Notification) {
        self.viewWillAppear(true)
    }
    

}
