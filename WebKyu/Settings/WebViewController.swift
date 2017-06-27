//
//  ViewController.swift
//  WebKyu
//
//  Created by yan on 2017/06/27.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet
    weak var webView: UIWebView!
    var url: URL?
    var localUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = self.url {
            self.webView.loadRequest(URLRequest(url: url))
        } else if let url = self.localUrl {
            do {
                let html = try String(contentsOf: url)
                self.webView.loadHTMLString(html, baseURL: nil)
            } catch {
                print(error)
            }
        }
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

}
