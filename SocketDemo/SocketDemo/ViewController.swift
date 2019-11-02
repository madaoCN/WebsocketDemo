//
//  ViewController.swift
//  SocketDemo
//
//  Created by 梁宪松 on 2019/9/12.
//  Copyright © 2019 madao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var connectUrlField: UITextField!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var inputContentField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var uploadImageBtn: UIButton!
    
    var dataSource =  [Dictionary<String, String>]()
    
    lazy var socketConnect: SocketConnect = {
        let connect = SocketConnect.init()
        
        connect.receiveTextBlock = {obj in
            
            if let dictArrObj = obj as? Array<Dictionary<String, String>> {
                self.dataSource.append(contentsOf: dictArrObj.reversed())
                self.contentTableView.reloadData()
            }
            else if let dictObj = obj as? Dictionary<String, String> {
                self.dataSource.insert(dictObj, at: 0)
                self.contentTableView.reloadData()
            }
        }
        
        connect.didOpenBlock = {obj in
            self.changeStatus("connected")
            self.dataSource.removeAll()
            self.connectBtn.isSelected = true
        }
        
        connect.didCloseBlock = {obj in
            self.changeStatus("closed")
            self.connectBtn.isSelected = false
        }
        
        return connect
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        self.contentTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.self.description())
    }
    
    func changeStatus(_ msg: String) {
        self.statusLabel.text = msg
    }
    
    @IBAction func handleConnect(_ sender: Any) {
        
        if self.connectBtn.isSelected == false {
            
            self.changeStatus("connecting")
            self.socketConnect.url = self.connectUrlField.text
            self.socketConnect.open()
        } else {
            
            self.socketConnect.close()
        }
    }
    
    @IBAction func handleSend(_ sender: Any) {
        
        guard let content = self.inputContentField.text else {
            return
        }
        self.socketConnect.send(["body": content])
    }
    
    @IBAction func handleUploadImage(_ sender: Any) {
        
        let picPath = Bundle.main.path(forResource: "eva", ofType: "jpg")
        guard let path = picPath else {
            
            return
        }
        
        let image = UIImage.init(contentsOfFile: path)
        guard let img = image else {
            
            return
        }
        
        self.socketConnect.send(img)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.self.description())
        
        let dict = self.dataSource[indexPath.row]
        if let content = dict["body"] {
            cell?.textLabel?.text = content
        }
        
        return cell ?? UITableViewCell.init()
    }
}

