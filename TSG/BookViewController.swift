//
//  BookViewController.swift
//  TSG
//
//  Created by 俞佳兴 on 2020/10/29.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BookViewController: UIViewController {
    
    @IBOutlet var bookButton: UIButton! {
        didSet {
            bookButton.layer.cornerRadius = 8.0
            bookButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var daySelectControl: UISegmentedControl!
    
    var mobile = ""
    
    var defaultDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "2020/10/29")!
    }
    
    var indexPaths: [IndexPath] = [] {
        didSet {
            if indexPaths.count != 0 {
                bookButton.isEnabled = true
                bookButton.backgroundColor = .systemBlue
            } else {
                bookButton.isEnabled = false
                bookButton.backgroundColor = .gray
            }
        }
    }
    
    let library: [String] = ["基础馆", "西溪馆", "农医馆", "华家池馆", "玉泉401阅览室", "玉泉420阅览室", "玉泉300阅览室", "玉泉501阅览室", "玉泉520阅览室", "玉泉701阅览室", "玉泉320阅览室", "玉泉820阅览室"]
    
    let libraryTodayID: [String : Int] = [
        "基础馆" : 1580,
        "西溪馆" : 2076,
        "农医馆" : 1828,
        "华家池馆" : 1332,
        "玉泉401阅览室" : 3812,
        "玉泉420阅览室" : 3564,
        "玉泉300阅览室" : 2324,
        "玉泉501阅览室" : 3068,
        "玉泉520阅览室" : 3316,
        "玉泉701阅览室" : 4045,
        "玉泉320阅览室" : 4278,
        "玉泉820阅览室" : 4744
    ]
    
    let libraryTomorrowID: [String : Int] = [
        "基础馆" : 1581,
        "西溪馆" : 2077,
        "农医馆" : 1829,
        "华家池馆" : 1333,
        "玉泉401阅览室" : 3813,
        "玉泉420阅览室" : 3565,
        "玉泉300阅览室" : 2325,
        "玉泉501阅览室" : 3069,
        "玉泉520阅览室" : 3317,
        "玉泉701阅览室" : 4046,
        "玉泉320阅览室" : 4279,
        "玉泉820阅览室" : 4745
    ]
    
    var timer: Timer!
    
    var isSuccess = false {
        didSet {
            UserDefaults.standard.set(isSuccess, forKey: "isSuccess")
        }
    }
    
    var isTomorrow = false
    
    var bookedLibrary = "" {
        didSet {
            UserDefaults.standard.set(bookedLibrary, forKey: "bookedLibrary")
        }
    }
    var bookedLibraryID = "" {
        didSet {
            UserDefaults.standard.set(bookedLibraryID, forKey: "bookedLibraryID")
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        if isSuccess {
            let alertController = UIAlertController(title: "取消预约\(bookedLibrary)？", message: "", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "确定", style: .destructive) { (action) in
                self.cancelBooking(id: self.bookedLibraryID)
            }
            let action2 = UIAlertAction(title: "取消", style: .default) { (action) in
                
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(booking), userInfo: nil, repeats: true)
            timer.fire()
            bookButton.isEnabled = false
            bookButton.setTitle("正在预约中", for: .normal)
            tableView.isUserInteractionEnabled = false
            bookButton.backgroundColor = .gray
        }
    }
    
    @objc func booking() {
        let date = daySelectControl.selectedSegmentIndex
        for indexPath in indexPaths {
            let libraryIndex = indexPath.row
            var libraryID = ""
            print(Date.daysBetween(start: defaultDate, end: Date()))
            if date == 0 {
                libraryID = String(libraryTodayID[library[libraryIndex]]! + Date.daysBetween(start: defaultDate, end: Date()))
            } else {
                libraryID = String(libraryTomorrowID[library[libraryIndex]]! + Date.daysBetween(start: defaultDate, end: Date()))
            }
            
            self.book(id: libraryID, libraryName: library[libraryIndex])
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if let bookedLibrary = UserDefaults.standard.string(forKey: "bookedLibrary") {
            self.bookedLibrary = bookedLibrary
        }
        
        if let bookedLibraryID = UserDefaults.standard.string(forKey: "bookedLibraryID") {
            self.bookedLibraryID = bookedLibraryID
        }
        
        isSuccess = UserDefaults.standard.bool(forKey: "isSuccess")
        
        if isSuccess {
            bookButton.isEnabled = true
            bookButton.backgroundColor = .gray
            bookButton.setTitle("已预约：\(bookedLibrary)", for: .normal)
            tableView.isUserInteractionEnabled = false

        } else {
            bookButton.isEnabled = false
            bookButton.backgroundColor = .gray
        }
        
    }
    
    func cancelBooking(id: String) {
        let parameters: [String: String] = [
            "id" : id,
        ]
        
        let headers: [String : String] = [
            "Accept" : "*/*",
            "Accept-Encoding" : "gzip, deflate",
            "Accept-Language" : "zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7",
            "Host" : "10.203.97.155",
            "Referer" : "http://10.203.97.155/book/notice/act_id/1580/type/4/lib/11"
        ]

        Alamofire.request("http://10.203.97.155/api.php/activities/" + id + "/quit", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let msg = jsonResponse["msg"].stringValue
                if msg == "取消成功" {
                    let alertController = UIAlertController(title: "取消成功", message: "", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.isSuccess = false
                        self.bookedLibraryID = ""
                        self.bookedLibrary = ""
                        self.bookButton.isEnabled = true
                        self.bookButton.setTitle("开始预约", for: .normal)
                        self.bookButton.backgroundColor = .systemBlue
                        self.tableView.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    func book(id: String, libraryName: String) {
        let parameters: [String: String] = [
            "mobile" : mobile,
            "id" : id,
        ]
        
        let headers: [String : String] = [
            "Accept" : "*/*",
            "Accept-Encoding" : "gzip, deflate",
            "Accept-Language" : "zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7",
            "Host" : "10.203.97.155",
            "Referer" : "http://10.203.97.155/book/notice/act_id/1580/type/4/lib/11"
        ]

        Alamofire.request("http://10.203.97.155/api.php/activities/" + id + "/application2", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                print(jsonResponse["msg"].stringValue)
                let msg = jsonResponse["msg"].stringValue
                if msg == "活动申请失败，已申请的活动时间冲突！" && !self.isSuccess {
                    self.timer.invalidate()
                    
                    let alertController = UIAlertController(title: "当日存在已预约的图书馆", message: "", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.bookButton.isEnabled = true
                        self.bookButton.setTitle("开始预约", for: .normal)
                        self.bookButton.backgroundColor = .systemBlue
                        self.tableView.isUserInteractionEnabled = true
                    }
                } else if msg == "活动申请时间 已截止" && !self.isSuccess {
                    self.timer.invalidate()
                    
                    let alertController = UIAlertController(title: "当日图书馆申请时间已截止", message: "", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.bookButton.isEnabled = true
                        self.bookButton.setTitle("开始预约", for: .normal)
                        self.bookButton.backgroundColor = .systemBlue
                        self.tableView.isUserInteractionEnabled = true
                    }
                } else if msg == "申请成功" {
                    self.timer.invalidate()
                    self.isSuccess = true
                    self.bookedLibrary = libraryName
                    self.bookedLibraryID = id
                    
                    self.bookButton.isEnabled = true
                    self.bookButton.backgroundColor = .gray
                    self.bookButton.setTitle("已预约：\(libraryName)", for: .normal)
                    self.tableView.isUserInteractionEnabled = false
                    
                    let alertController = UIAlertController(title: "\(libraryName)申请成功", message: "", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                    }
                } else if msg == "本馆开放预约时间<br/>07:00:00  -23:59:59  " {
                    self.timer.invalidate()
                    
                    let alertController = UIAlertController(title: "本馆开放预约时间：07:00:00 - 23:59:59", message: "", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.bookButton.isEnabled = true
                        self.bookButton.setTitle("开始预约", for: .normal)
                        self.bookButton.backgroundColor = .systemBlue
                        self.tableView.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPaths.removeAll()
        if let idp = tableView.indexPathsForSelectedRows {
            self.indexPaths = idp
            if idp.count != 0 {
                bookButton.isEnabled = true
                bookButton.backgroundColor = .systemBlue
            } else {
                bookButton.isEnabled = false
                bookButton.backgroundColor = .gray
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        indexPaths.removeAll()
        if let idp = tableView.indexPathsForSelectedRows {
            self.indexPaths = idp
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryTableViewCell
        
        cell.libraryNameLabel.text = library[indexPath.row]
        
        return cell
    }
    
    
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    public static func daysBetween(start: Date, end: Date) -> Int {
       Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}
