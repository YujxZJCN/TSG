//
//  SettingViewController.swift
//  TSG
//
//  Created by 俞佳兴 on 2021/1/3.
//  Copyright © 2021 yjx. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet var resetToDefaultButton: UIButton! {
        didSet {
            resetToDefaultButton.clipsToBounds = true
            resetToDefaultButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var saveChangeButton: UIButton! {
        didSet {
            saveChangeButton.clipsToBounds = true
            saveChangeButton.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
