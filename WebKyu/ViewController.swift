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
import EasyAnimation
import ImageIO
import Kingfisher

extension Notification.Name {
    static let BookmarksDataSourceUpdate = Notification.Name("mmd.PuppyBrowser.bookmarksDataSourceUpdate")
}

class ViewController: UIViewController {
    
    var _imageCount: Int = 0
   
    var _webView: UIWebView?

    @IBOutlet
    weak var _webContainer: UIView!
    
    @IBOutlet
    weak var _backButton: UIButton!
    
    @IBOutlet
    weak var _forwardButton: UIButton!
    
    @IBOutlet
    weak var _stopButton: UIButton!

    @IBOutlet
    weak var _attectionButton: UIButton!
    
    @IBOutlet
    weak var _filterButton: UIButton!

    @IBOutlet
    weak var _countButton: UIButton!
    
    @IBOutlet
    weak var urlTextField: UITextField!

    @IBOutlet
    weak var collectionView: UICollectionView?

    private var _timer: Timer?

    private var _updateBookmarks: Bool = false

//    fileprivate var images: [MWPhoto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        NotificationCenter.default.addObserver(self, selector: #selector(bookmarksDataSourceUpdated), name: .BookmarksDataSourceUpdate, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func bookmarksDataSourceUpdated() {
        _updateBookmarks = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if _updateBookmarks {
            _updateBookmarks = false
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadUrl(url: URL) {
        self.collectionView?.removeFromSuperview()
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
            _timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkImages), userInfo: nil, repeats: true)
        }
        _webView!.loadRequest(URLRequest(url: url))
    }
    
    func checkImages() {
        let images = Global.share.images(withFilterOptions: nil)
        
        if _imageCount != images.count {
            _imageCount = images.count
            
            _countButton.setTitle("\(_imageCount)", for: .normal)
            UIView.animateAndChain(withDuration: 0.15, delay: 0, options: [], animations: {
                self._countButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil).animate(withDuration: 0.15, animations: {
                self._countButton.transform = CGAffineTransform.identity
            })
        }
    }

    @IBAction func toggleAttection(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
//        _filterButton.isEnabled = sender.isSelected
        _countButton.isEnabled = sender.isSelected
        MDURLProtocol.tracking = sender.isSelected
    }

    @IBAction func filterButtonPressed(_ sender: UIButton) {
        
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BookmarkManager.shared.bookmarks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmark", for: indexPath) as! BookmarkCollectionViewCell

        let bookmark = BookmarkManager.shared.bookmarks[indexPath.row]
        if let url = bookmark.favIconUrl {
            cell.imageView.kf.setImage(with: ImageResource(downloadURL: url))
        } else {
            cell.imageView.image = nil
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookmark = BookmarkManager.shared.bookmarks[indexPath.row]
        self.loadUrl(url: bookmark.url)
        self.urlTextField.text = bookmark.url.absoluteString
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

