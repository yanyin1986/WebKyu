//
//  AddBookmarkViewController.swift
//  WebKyu
//
//  Created by Leon.yan on 24/06/2017.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class AddBookmarkViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard var urlStr = textField.text else {
            return false
        }

        if !urlStr.hasPrefix("http://") && !urlStr.hasPrefix("https://") {
            urlStr = "http://" + urlStr
        }

        guard let url = URL(string: urlStr) else {
            // invalid url
            return false
        }

        self.detectFav(withUrl: url)
        return true
    }

    private func detectFav(withUrl url: URL) {

    }

}
