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
    weak var collectionView: UICollectionView!

    private var _timer: Timer?

//    fileprivate var images: [MWPhoto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadUrl(url: URL) {
        self.collectionView.removeFromSuperview()
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

//    @IBAction func showPhotoBrowser(_ sender: Any) {
////        self.images.removeAll()
////        self.images.append(contentsOf: Global.share.mwPhoto())
//
//        let browser = PhotoBrowser(showByViewController: self, delegate: self)
//        browser.show(index: 0)
//        /*
//        guard let browser = MWPhotoBrowser(delegate: self) else {
//            return
//        }
//
//        browser.displayActionButton = true
//        browser.displayNavArrows = true
//        browser.displaySelectionButtons = false // Whether selection buttons are shown on each image (defaults to NO)
//        browser.zoomPhotosToFill = true
//        browser.alwaysShowControls = true
//        browser.enableGrid = true
//        browser.startOnGrid = true
//
//        self.navigationController?.pushViewController(browser, animated: true)
// */
//        //(browser, animated: true, completion: nil)
//    }

    @IBAction func toggleAttection(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _filterButton.isEnabled = sender.isSelected
        _countButton.isEnabled = sender.isSelected
        MDURLProtocol.tracking = sender.isSelected
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
//
//extension ViewController: PhotoBrowserDelegate {
//    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
//        return Global.share.images().count
//    }
//
//    /// 实现本方法以返回默认图片，缩略图或占位图
//    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
//        let image = Global.share.images()[index]
//        guard let src = CGImageSourceCreateWithURL(image.url as CFURL, nil) else {
//            return nil
//        }
//        let scale = UIScreen.main.scale
//        let w = (UIScreen.main.bounds.width / 3) * scale
//        let d : [NSObject:AnyObject] = [
//            kCGImageSourceShouldAllowFloat : true as AnyObject,
//            kCGImageSourceCreateThumbnailWithTransform : true as AnyObject,
//            kCGImageSourceCreateThumbnailFromImageAlways : true as AnyObject,
//            kCGImageSourceThumbnailMaxPixelSize : w as AnyObject
//        ]
//        let imref = CGImageSourceCreateThumbnailAtIndex(src, 0, d as CFDictionary)
//        return UIImage(cgImage: imref!, scale: scale, orientation: .up)
//    }
//
//    /// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
//    /// 比如你可返回ImageView，或整个Cell
//    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
//        return
//    }
//
//    /// 实现本方法以返回高质量图片。可选
//    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityImageForIndex index: Int) -> UIImage? {
//        return UIImage(contentsOfFile: Global.share.images()[index].url.path)
//    }
//
//    /// 长按时回调。可选
//    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
//
//    }
//}

/*
extension ViewController: MWPhotoBrowserDelegate {

    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.images.count)
    }

    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        return self.images[Int(index)]
    }

    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, thumbPhotoAt index: UInt) -> MWPhotoProtocol! {
        return self.images[Int(index)]
    }

}
 */

