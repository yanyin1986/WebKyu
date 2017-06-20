//
//  CachedViewController.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit
import YYImage
import JXPhotoBrowser
import ImageIO
import SnapKit

class CachedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet
    weak var collectionView: UICollectionView!
    var images: [Image] = []
    weak var photoBrowser: PhotoBrowser?
    var currentIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        images = Global.share.images()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollcetionViewCell
        let img = images[indexPath.row]
        let path = MDStoreage.shared.imageCache().cachePath(forKey: img.url.absoluteString)
        let image = YYImage(contentsOfFile: path)
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.width - 10) / 3.0)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = PhotoBrowser(showByViewController: self, delegate: self)
        browser.pageControlDelegate = self
        browser.definesPresentationContext = true
        browser.show(index: indexPath.row)
        currentIndex = indexPath.row

        photoBrowser = browser
    }

    lazy var toolView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let button = UIButton(frame: CGRect(x: 270, y: 0, width: 50, height: 50))
        button.addTarget(self, action: #selector(share(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints({ (make) in
            make.width.equalTo(50)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        })
        return view
    }()

    @objc
    func share(_ sender: UIButton) {
        guard let browser = photoBrowser else {
            return
        }

        let url = images[currentIndex].url
        let imageCache = MDStoreage.shared.imageCache()
        let cacheResult = imageCache.isImageCached(forKey: url.absoluteString)
        guard cacheResult.cached else {
            return
        }

        let path = imageCache.cachePath(forKey: url.absoluteString)
        guard let image = UIImage(contentsOfFile: path) else {
            return
        }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        browser.present(activity, animated: true, completion: nil)
//        let alert = UIAlertController(title: "a", message: "message", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

//        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension CachedViewController: PhotoBrowserDelegate {

    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return images.count
    }

    /// 实现本方法以返回默认图片，缩略图或占位图
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        let image = images[index]
        guard let src = CGImageSourceCreateWithURL(image.url as CFURL, nil) else {
            return nil
        }

        let scale = UIScreen.main.scale
        let w = (UIScreen.main.bounds.width / 4) * scale
        let d : [NSObject : Any] = [
            kCGImageSourceShouldAllowFloat : true,
            kCGImageSourceCreateThumbnailWithTransform : true,
            kCGImageSourceCreateThumbnailFromImageAlways : true,
            kCGImageSourceThumbnailMaxPixelSize : w
        ]
        let imref = CGImageSourceCreateThumbnailAtIndex(src, 0, d as CFDictionary)
        return UIImage(cgImage: imref!, scale: scale, orientation: .up)
    }

    /// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
    /// 比如你可返回ImageView，或整个Cell
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return collectionView.cellForItem(at: IndexPath(row: index, section: 0))
    }

    /// 实现本方法以返回高质量图片。可选
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityImageForIndex index: Int) -> UIImage? {
        return UIImage(contentsOfFile: images[index].url.path)
    }

    /// 长按时回调。可选
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {

    }

}

extension CachedViewController: PhotoBrowserPageControlDelegate {

    func pageControlOfPhotoBrowser(_ photoBrowser: PhotoBrowser) -> UIView {
        return toolView
    }

    /// 添加到父视图上时调用
    func photoBrowserPageControl(_ pageControl: UIView, didMoveTo superView: UIView) {

    }

    /// 让pageControl布局时调用
    func photoBrowserPageControl(_ pageControl: UIView, needLayoutIn superView: UIView) {
        pageControl.frame = CGRect(x: 0, y: superView.frame.height - 50, width: superView.frame.width, height: 50)
    }

    /// 页码变更时调用
    func photoBrowserPageControl(_ pageControl: UIView, didChangedCurrentPage currentPage: Int) {
        self.currentIndex = currentPage
    }
}

