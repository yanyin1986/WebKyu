//
//  ViewController.swift
//  WebKyu
//
//  Created by yan on 2017/02/28.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {
    
    var _webView: UIWebView?
    @IBOutlet weak var _webContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadUrl(url: URL) {
        if _webView == nil {
            _webView = UIWebView(frame: self.view.bounds)
            _webView!.backgroundColor = UIColor.white
            _webView?.scrollView.backgroundColor = UIColor.white
            
            let top: CGFloat
            if let navBarHeight = self.navigationController?.navigationBar.frame.height,
                navBarHeight > 0 {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                top = navBarHeight + statusBarHeight
                _webView?.scrollView.clipsToBounds = false
            } else {
                top = 0
            }
            let bottom = 50
            
            _webContainer.addSubview(_webView!)
            _webView!.snp.makeConstraints({ (make) in
                make.leading.equalTo(_webContainer.snp.leading)
                make.trailing.equalTo(_webContainer.snp.trailing)
                make.top.equalTo(_webContainer.snp.top).offset(top)
                make.bottom.equalTo(_webContainer.snp.bottom).offset(-bottom)
            })
            
            //
            URLProtocol.registerClass(MDURLProtocol.self)
        }
        _webView!.loadRequest(URLRequest(url: url))
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var path = textField.text {
            if !path.hasPrefix("http://") && !path.hasPrefix("https://") {
                path = "http://" + path
            }
            
            if let url = URL(string: path) {
                self.loadUrl(url: url)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}

