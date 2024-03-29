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
import Kanna
import NVActivityIndicatorView

class BookViewController: UIViewController {
    
    @IBOutlet var bookButton: UIButton! {
        didSet {
            bookButton.layer.cornerRadius = 8.0
            bookButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var menuView: UIView!
    
    
    @IBOutlet var daySelectControl: UISegmentedControl!
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dayChange(_ sender: UISegmentedControl) {
        print(daySelectControl.selectedSegmentIndex)
        if daySelectControl.selectedSegmentIndex == 0 {
            isTomorrow = false
        } else {
            isTomorrow = true
        }
        
        tableView.reloadData()
    }
    var mobile = "" {
        didSet {
            print(mobile)
        }
    }
    
    lazy var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: self.menuView.frame.size.width / 2 - 20, y: self.menuView.frame.size.height / 2 - 20, width: 40, height: 40), type: .ballSpinFadeLoader, color: UIColor(dynamicProvider: { (trait) -> UIColor in
        if trait.userInterfaceStyle == .dark {
            return .white
        } else {
            return .black
        }
    }), padding: .none)
    
    var defaultDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "2021/01/01")!
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
        "基础馆" : 5177,
        "西溪馆" : 5907,
        "农医馆" : 5542,
        "华家池馆" : 4812,
        "玉泉401阅览室" : 7002,
        "玉泉420阅览室" : 7367,
        "玉泉300阅览室" : 6272,
        "玉泉501阅览室" : 7732,
        "玉泉520阅览室" : 8097,
        "玉泉701阅览室" : 8462,
        "玉泉320阅览室" : 6637,
        "玉泉820阅览室" : 8827
    ]
    
    let libraryTomorrowID: [String : Int] = [
        "基础馆" : 5178,
        "西溪馆" : 5908,
        "农医馆" : 5543,
        "华家池馆" : 4813,
        "玉泉401阅览室" : 7003,
        "玉泉420阅览室" : 7368,
        "玉泉300阅览室" : 6273,
        "玉泉501阅览室" : 7733,
        "玉泉520阅览室" : 8098,
        "玉泉701阅览室" : 8463,
        "玉泉320阅览室" : 6638,
        "玉泉820阅览室" : 8828
    ]
    
    var timer: Timer!
    
    var sleepTimer: Timer!
    
    var freeNumber: [Int : Int] = [:] {
        didSet {
            if freeNumber.count == libraryTodayID.values.count + libraryTomorrowID.values.count {
                print(freeNumber)
                tableView.reloadData()
            }
        }
    }
    var totalNumber: [Int : Int] = [:] {
        didSet {
            if freeNumber.count == libraryTodayID.values.count + libraryTomorrowID.values.count {
                print(totalNumber)
                tableView.reloadData()
            }
        }
    }
    
    var isSuccess = false {
        didSet {
            if isTomorrow {
                UserDefaults.standard.set(isSuccess, forKey: "\(globalStudentID)tomorrow_isSuccess")
            } else {
                UserDefaults.standard.set(isSuccess, forKey: "\(globalStudentID)today_isSuccess")
            }
        }
    }
    
    var isTomorrow = false {
        didSet {
            if isTomorrow {
                if let bookedLibrary = UserDefaults.standard.string(forKey: "\(globalStudentID)tomorrow_bookedLibrary") {
                    self.bookedLibrary = bookedLibrary
                }
                
                if let bookedLibraryID = UserDefaults.standard.string(forKey: "\(globalStudentID)tomorrow_bookedLibraryID") {
                    self.bookedLibraryID = bookedLibraryID
                }
                
                isSuccess = UserDefaults.standard.bool(forKey: "\(globalStudentID)tomorrow_isSuccess")
                
                if isSuccess {
                    bookButton.isEnabled = true
                    bookButton.backgroundColor = .gray
                    bookButton.setTitle("已预约：\(bookedLibrary)", for: .normal)
                    tableView.isUserInteractionEnabled = false
                } else {
                    if indexPaths.isEmpty {
                        bookButton.isEnabled = false
                        bookButton.backgroundColor = .gray
                        tableView.isUserInteractionEnabled = true
                        bookButton.setTitle("开始预约", for: .normal)
                    } else {
                        bookButton.isEnabled = true
                        bookButton.backgroundColor = .systemBlue
                        tableView.isUserInteractionEnabled = true
                        bookButton.setTitle("开始预约", for: .normal)
                    }
                }
            } else {
                if let bookedLibrary = UserDefaults.standard.string(forKey: "\(globalStudentID)today_bookedLibrary") {
                    self.bookedLibrary = bookedLibrary
                }
                
                if let bookedLibraryID = UserDefaults.standard.string(forKey: "\(globalStudentID)today_bookedLibraryID") {
                    self.bookedLibraryID = bookedLibraryID
                }
                
                isSuccess = UserDefaults.standard.bool(forKey: "\(globalStudentID)today_isSuccess")
                
                if isSuccess {
                    bookButton.isEnabled = true
                    bookButton.backgroundColor = .gray
                    bookButton.setTitle("已预约：\(bookedLibrary)", for: .normal)
                    tableView.isUserInteractionEnabled = false

                } else {
                    if indexPaths.isEmpty {
                        bookButton.isEnabled = false
                        bookButton.backgroundColor = .gray
                        tableView.isUserInteractionEnabled = true
                        bookButton.setTitle("开始预约", for: .normal)
                    } else {
                        bookButton.isEnabled = true
                        bookButton.backgroundColor = .systemBlue
                        tableView.isUserInteractionEnabled = true
                        bookButton.setTitle("开始预约", for: .normal)
                    }
                }
            }
        }
    }
    
    var bookedLibrary = "" {
        didSet {
            if isTomorrow {
                UserDefaults.standard.set(bookedLibrary, forKey: "\(globalStudentID)tomorrow_bookedLibrary")
            } else {
                UserDefaults.standard.set(bookedLibrary, forKey: "\(globalStudentID)today_bookedLibrary")
            }
        }
    }
    var bookedLibraryID = "" {
        didSet {
            if isTomorrow {
                UserDefaults.standard.set(bookedLibraryID, forKey: "\(globalStudentID)tomorrow_bookedLibraryID")
            } else {
                UserDefaults.standard.set(bookedLibraryID, forKey: "\(globalStudentID)today_bookedLibraryID")
            }
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
            let buttonTitle = bookButton.title(for: .normal)!
            if buttonTitle.contains("正在预约中") {
                self.timer.invalidate()
                self.bookButton.isEnabled = true
                self.daySelectControl.isEnabled = true
                self.bookButton.setTitle("开始预约", for: .normal)
                self.bookButton.backgroundColor = .systemBlue
                self.tableView.isUserInteractionEnabled = true
                self.tryTimes = 0
            } else {
                if !indexPaths.isEmpty {
                    timer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(booking), userInfo: nil, repeats: true)
                    timer.fire()
                    bookButton.isEnabled = true
                    bookButton.setTitle("正在预约中", for: .normal)
                    tableView.isUserInteractionEnabled = false
                    daySelectControl.isEnabled = false
                    bookButton.backgroundColor = .gray
                }
            }
        }
    }
    
    var tryTimes = 0 {
        didSet {
//            if tryTimes % 10 == 0 && tryTimes != 0 {
//                timer.invalidate()
//                sleepTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(sleepForThreeSeconds), userInfo: nil, repeats: true)
//                sleepTimer.fire()
//            }
        }
    }
    
    var isSleeping = false
    
    @objc func sleepForThreeSeconds() {
        if !isSleeping {
            DispatchQueue.main.async {
                self.bookButton.setTitle("休息一下", for: .normal)
            }
            isSleeping = true
        } else {
            sleepTimer.invalidate()
            DispatchQueue.main.async {
                self.bookButton.setTitle("正在预约中（\(self.tryTimes)）", for: .normal)
            }
            timer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(booking), userInfo: nil, repeats: true)
            timer.fire()
            isSleeping = false
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
            tryTimes += 1
            bookButton.setTitle("正在预约中（\(tryTimes)）", for: .normal)
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
        
        self.bookButton.isEnabled = false
        self.bookButton.alpha = 0.0
        self.daySelectControl.alpha = 0.0
        self.menuView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        checkBookedLibrary()
        
        for lib in libraryTodayID.values {
            let libID = lib + Date.daysBetween(start: self.defaultDate, end: Date())
            revervationNumberCheck(libID: libID)
        }
        
        for lib in libraryTomorrowID.values {
            let libID = lib + Date.daysBetween(start: self.defaultDate, end: Date())
            revervationNumberCheck(libID: libID)
        }
    }
    
    func revervationNumberCheckURL(libID: Int) -> String {
        return "http://10.203.97.155/book/notice/act_id/\(libID)/type/4/lib/11"
    }
    
    func revervationNumberCheck(libID: Int) {
        let checkURL = revervationNumberCheckURL(libID: libID)
        Alamofire.request(checkURL, method: .get).responseData { (response) in
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                if let content = doc.content {
                    var components = content.components(separatedBy: "预约人数：[")
                    if components.count > 1 {
                        var tempStr = components[1]
                        components = tempStr.components(separatedBy: "]\r\n")
                        tempStr = components[0]
                        components = tempStr.components(separatedBy: "/")
                        if components.count > 1 {
                            let freeN = Int(components[0])
                            let totalN = Int(components[1])
                            self.freeNumber[libID] = freeN
                            self.totalNumber[libID] = totalN
                        }
                    }
                }
            }
        }
    }
    
    func checkBookedLibrary() {
        Alamofire.request("http://10.203.97.155/user/index/activity2", method: .get).responseData { (response) in
//            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                UserDefaults.standard.set(false, forKey: "\(globalStudentID)today_isSuccess")
                UserDefaults.standard.set("", forKey: "\(globalStudentID)today_bookedLibrary")
                UserDefaults.standard.set("", forKey: "\(globalStudentID)today_bookedLibraryID")
                
                UserDefaults.standard.set(false, forKey: "\(globalStudentID)tomorrow_isSuccess")
                UserDefaults.standard.set("", forKey: "\(globalStudentID)tomorrow_bookedLibrary")
                UserDefaults.standard.set("", forKey: "\(globalStudentID)tomorrow_bookedLibraryID")
                
                for content in doc.css("td") {
                    if let innerHtml = content.innerHTML, innerHtml.contains("menuCheckOut") {
                        print(innerHtml.components(separatedBy: "menuCheckOut('")[1].components(separatedBy: "')")[0])
                        let fetchedID = innerHtml.components(separatedBy: "menuCheckOut('")[1].components(separatedBy: "')")[0]
                        for lib in self.library {
                            let libID = self.libraryTodayID[lib]! + Date.daysBetween(start: self.defaultDate, end: Date())
                            if String(libID) == fetchedID {
                                UserDefaults.standard.set(true, forKey: "\(globalStudentID)today_isSuccess")
                                UserDefaults.standard.set(lib, forKey: "\(globalStudentID)today_bookedLibrary")
                                UserDefaults.standard.set(libID, forKey: "\(globalStudentID)today_bookedLibraryID")
                            }
                        }
                        
                        for lib in self.library {
                            let libID = self.libraryTomorrowID[lib]! + Date.daysBetween(start: self.defaultDate, end: Date())
                            if String(libID) == fetchedID {
                                UserDefaults.standard.set(true, forKey: "\(globalStudentID)tomorrow_isSuccess")
                                UserDefaults.standard.set(lib, forKey: "\(globalStudentID)tomorrow_bookedLibrary")
                                UserDefaults.standard.set(libID, forKey: "\(globalStudentID)tomorrow_bookedLibraryID")
                            }
                        }
                    }
                }
                
                if let bookedLibrary = UserDefaults.standard.string(forKey: "\(globalStudentID)today_bookedLibrary") {
                    self.bookedLibrary = bookedLibrary
                }
                
                if let bookedLibraryID = UserDefaults.standard.string(forKey: "\(globalStudentID)today_bookedLibraryID") {
                    self.bookedLibraryID = bookedLibraryID
                }
                
                self.isSuccess = UserDefaults.standard.bool(forKey: "\(globalStudentID)today_isSuccess")
                
                if self.isSuccess {
                    self.bookButton.isEnabled = true
                    self.bookButton.backgroundColor = .gray
                    self.bookButton.setTitle("已预约：\(self.bookedLibrary)", for: .normal)
                    self.tableView.isUserInteractionEnabled = false
                } else {
                    self.bookButton.isEnabled = false
                    self.bookButton.backgroundColor = .gray
                }
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.removeFromSuperview()
                self.bookButton.alpha = 1.0
                self.daySelectControl.alpha = 1.0
            }
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
        
        Alamofire.request("http://10.214.242.11:1988/?username=\(globalStudentID)&password=\(globalPassword)", method: .get).responseString { (response) in
            
            if let ticketURL = response.result.value {
                
                Alamofire.request(ticketURL, method: .post).response { (response) in
                    self.showAndSetCookies()
                    
                    Alamofire.request("http://10.203.97.155/api.php/activities/" + id + "/quit", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
                        if let responseStr = response.result.value {
                            let jsonResponse = JSON(responseStr)
                            let msg = jsonResponse["msg"].stringValue
                            print(msg)
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
                            } else if msg == "退出失败，请重试" {
                                let alertController = UIAlertController(title: "已在网页端取消预约", message: "", preferredStyle: .alert)
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
            "Accept-Language" : "zh-cn",
            "Host" : "10.203.97.155",
            "Referer" : "http://10.203.97.155/book/notice/act_id/1622/type/4/lib/11",
            "Connection" : "keep-alive"
        ]
                
        Alamofire.request("http://10.214.242.11:1988/?username=\(globalStudentID)&password=\(globalPassword)", method: .get).responseString { (response) in
            
            if let ticketURL = response.result.value {
                
                Alamofire.request(ticketURL, method: .post).response { (response) in
                    self.showAndSetCookies()
                    
                    Alamofire.request("http://10.203.97.155/api.php/activities/" + id + "/application2", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
                        if let responseStr = response.result.value {
                            let jsonResponse = JSON(responseStr)
                            print(jsonResponse["msg"].stringValue)
                            let msg = jsonResponse["msg"].stringValue
                            if msg == "活动申请失败，已申请的活动时间冲突！" && !self.isSuccess {
                                self.timer.invalidate()
                                self.tryTimes = 0
                                
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
                                self.tryTimes = 0
                                
                                let alertController = UIAlertController(title: "当日图书馆申请时间已截止", message: "", preferredStyle: .alert)
                                self.present(alertController, animated: true, completion: nil)
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                                    self.bookButton.isEnabled = true
                                    self.bookButton.setTitle("开始预约", for: .normal)
                                    self.bookButton.backgroundColor = .systemBlue
                                    self.tableView.isUserInteractionEnabled = true
                                    self.daySelectControl.isEnabled = true
                                }
                            } else if msg == "申请成功" {
                                self.timer.invalidate()
                                self.isSuccess = true
                                self.bookedLibrary = libraryName
                                self.bookedLibraryID = id
                                self.tryTimes = 0
                                
                                self.bookButton.isEnabled = true
                                self.bookButton.backgroundColor = .gray
                                self.bookButton.setTitle("已预约：\(libraryName)", for: .normal)
                                self.tableView.isUserInteractionEnabled = false
                                self.daySelectControl.isEnabled = true
                                
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
                                    self.daySelectControl.isEnabled = true
                                    self.tryTimes = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
    func showAndSetCookies() {

        let cookieStorage = HTTPCookieStorage.shared

        let cookies = cookieStorage.cookies as! [HTTPCookie]
        for cookie in cookies {
            var cookieProperties = [HTTPCookiePropertyKey: String]()

            cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
            cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
            cookieProperties[HTTPCookiePropertyKey.domain] = "10.203.97.155"
            cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
            cookieProperties[HTTPCookiePropertyKey.version] = String(cookie.version)
            cookieProperties[HTTPCookiePropertyKey.secure] = String(cookie.isSecure)
        }
    }

}

extension BookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        indexPaths.removeAll()
        var removedIndexPath: IndexPath? = nil
        if indexPaths.contains(indexPath) {
            indexPaths.removeAll { $0 == indexPath }
            removedIndexPath = indexPath
        } else {
            indexPaths.append(indexPath)
        }
//        if let idp = tableView.indexPathsForSelectedRows {
//            self.indexPaths = idp
//            if idp.count != 0 {
//                bookButton.isEnabled = true
//                bookButton.backgroundColor = .systemBlue
//            } else {
//                bookButton.isEnabled = false
//                bookButton.backgroundColor = .gray
//            }
//        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .none)
        if let rmvdIndexPath = removedIndexPath, let cell = tableView.cellForRow(at: rmvdIndexPath) as? LibraryTableViewCell {
            cell.checkImageView.alpha = 0.0
        }
        tableView.endUpdates()
        
//        for indexPath in indexPaths {
//            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        indexPaths.removeAll()
//        if let idp = tableView.indexPathsForSelectedRows {
//            self.indexPaths = idp
//        }
        if indexPaths.contains(indexPath) {
            indexPaths.removeAll { $0 == indexPath }
        } else {
            indexPaths.append(indexPath)
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .none)
        tableView.endUpdates()
        
//        for indexPath in indexPaths {
//            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPaths.contains(indexPath) { return 205.0 }
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell", for: indexPath) as! LibraryTableViewCell
        
        cell.libraryNameLabel.text = library[indexPath.row]
        
        if indexPaths.contains(indexPath) {
            cell.checkImageView.alpha = 1.0
        } else {
            cell.checkImageView.alpha = 0.0
        }
        
        if !isTomorrow {
            let libID = libraryTodayID[library[indexPath.row]]! + Date.daysBetween(start: defaultDate, end: Date())
            
            if let leftN = freeNumber[libID] {
                cell.leftNumberLabel.text = "\(leftN)"
            }
            
            if let totalN = totalNumber[libID] {
                cell.totalNumberLabel.text = "\(totalN)"
            }
        } else {
            let libID = libraryTomorrowID[library[indexPath.row]]! + Date.daysBetween(start: defaultDate, end: Date())
            
            if let leftN = freeNumber[libID] {
                cell.leftNumberLabel.text = String(leftN)
            }
            
            if let totalN = totalNumber[libID] {
                cell.totalNumberLabel.text = "\(totalN)"
            }
        }
        
        cell.selectionStyle = .none
        cell.animate()
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
