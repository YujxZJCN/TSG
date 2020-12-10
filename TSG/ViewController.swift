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
import Kanna

var globalStudentID = ""
var globalPassword = ""

class ViewController: UIViewController {
    
    var cookies: [HTTPCookie] = []
    
    var mobile = ""
        
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 8.0
            loginButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var studentIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        self.statusLabel.text = "正在登录"
        
        studentIDTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        let studentID = studentIDTextField.text!
        globalStudentID = studentID
        let password = passwordTextField.text!
        globalPassword = password
        
        UserDefaults.standard.set(studentID, forKey: "studentID")
        UserDefaults.standard.set(password, forKey: "\(studentID)_password")
        
        statusLabel.text = "准备获取门票"
        getAndValidateTicket(username: studentID, password: password)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusLabel.text = "浙大通行证"
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        let studentID = UserDefaults.standard.string(forKey: "studentID")
        let password = UserDefaults.standard.string(forKey: "\(studentID ?? "default")_password")
        studentIDTextField.text = studentID
        passwordTextField.text = password
    }
    
    func getAndValidateTicket(username: String, password: String) {
        statusLabel.text = "正在获取门票"
        Alamofire.request("http://10.214.242.11:1988/?username=\(username)&password=\(password)", method: .get).responseString { (response) in
            print(response.result.value ?? "Error")
            
            if let ticketURL = response.result.value {
                self.statusLabel.text = "门票获取成功，使用门票登录图书馆系统"
                
                Alamofire.request(ticketURL, method: .post).response { (response) in
                    self.statusLabel.text = "登录成功，设置Cookies"
                    self.showAndSetCookies()
                    
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookVC") as! BookViewController
                        vc.mobile = self.mobile
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
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

