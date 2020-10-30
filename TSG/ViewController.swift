//
//  ViewController.swift
//  TSG
//
//  Created by 俞佳兴 on 2020/10/29.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var cookies: [HTTPCookie] = []
    
    var mobile = ""
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 8.0
            loginButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var studentIDTextField: UITextField!
    @IBOutlet var verifyTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        self.statusLabel.text = "正在登录"
        
        studentIDTextField.resignFirstResponder()
        verifyTextField.resignFirstResponder()
                
        let studentID = studentIDTextField.text!
        let verifyCode = verifyTextField.text!
        
        UserDefaults.standard.set(studentID, forKey: "studentID")
        
        
        let parameters: [String: String] = [
            "username" : studentID,
            "password" : "c6f057b86584942e415435ffb1fa93d4",
            "verify" : verifyCode,
        ]
        
        let headers: [String : String] = [
            "Accept" : "application/json, text/javascript, */*; q=0.01",
            "Accept-Encoding" : "gzip, deflate",
            "Accept-Language" : "zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7",
            "Host" : "10.203.97.155",
            "Origin" : "http://10.203.97.155",
            "Referer" : "http://10.203.97.155/home/book/index/type/4",
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"
        ]

        Alamofire.request("http://10.203.97.155/api.php/login", method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let userName = jsonResponse["data"]["list"]["name"].stringValue
                let mobile = jsonResponse["data"]["list"]["mobile"].stringValue
                self.mobile = mobile
                print(jsonResponse)
                
                self.statusLabel.text = "登录成功"
                let cookieProps = [
                     HTTPCookiePropertyKey.domain: "10.203.97.155",
                     HTTPCookiePropertyKey.path: "/",
                     HTTPCookiePropertyKey.name: "user_name",
                     HTTPCookiePropertyKey.value: userName
                ]
                if let cookie = HTTPCookie(properties: cookieProps) {
                    self.cookies.append(cookie)
                }
                
                for name in jsonResponse["data"]["_hash_"].dictionary!.keys {
                    let cookieProps = [
                         HTTPCookiePropertyKey.domain: "10.203.97.155",
                         HTTPCookiePropertyKey.path: "/",
                         HTTPCookiePropertyKey.name: name,
                         HTTPCookiePropertyKey.value: jsonResponse["data"]["_hash_"][name].stringValue
                    ]
                    if let cookie = HTTPCookie(properties: cookieProps) {
                        self.cookies.append(cookie)
                    }
                }
                
                self.setCookies(cookies: self.cookies)
                
//                self.book(id: "3813")
                
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookVC") as! BookViewController
                    vc.mobile = self.mobile
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            } else {
                self.statusLabel.text = "登录失败"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusLabel.text = ""
        fetchTheCookies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let studentID = UserDefaults.standard.string(forKey: "studentID")
        studentIDTextField.text = studentID
    }

    func fetchTheCookies() {
        let parameters: [String: AnyObject] = [:]
        statusLabel.text = "正在获取Cookies"
        Alamofire.request("http://10.203.97.155/home/book/index/type/4", method: .get, parameters: parameters).responseJSON { response in
            if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url
            {
                 let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                self.cookies += cookies
                self.setCookies(cookies: self.cookies)
                self.statusLabel.text = "Cookies获取成功"

                let headers: [String : String] = [
                    "Accept" : "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
                    "Accept-Encoding" : "gzip, deflate",
                    "Accept-Language" : "zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7",
                    "Host" : "10.203.97.155",
                    "Referer" : "http://10.203.97.155/home/book/index/type/4"
                ]
                self.statusLabel.text = "正在获取验证码"
                
                Alamofire.request("http://10.203.97.155/api.php/check", method: .get, parameters: parameters, headers: headers).responseData { (response) in
                    if let downloadedImage = UIImage(data: response.data!) {
                        self.imageView.image = downloadedImage
                        self.statusLabel.text = "验证码获取成功"
                    }
                }
            }
        }
    }
    
    func setCookies(cookies: [HTTPCookie]) {
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: "10.203.97.155")!, mainDocumentURL: nil)
    }
    
    
}

