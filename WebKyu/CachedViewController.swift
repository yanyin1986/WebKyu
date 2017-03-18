//
//  CachedViewController.swift
//  WebKyu
//
//  Created by yan on 2017/03/01.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit

class CachedViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet
    weak var collectionView: UICollectionView!
    var images: [Image] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        images = Global.share.images()
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollcetionViewCell
        let img = images[indexPath.row]
        MDStoreage.shared.imageCache().retrieveImage(forKey: img.url.absoluteString, options: nil, completionHandler: { (image, _) in
            cell.imageView.image = image
        })
        return cell
    }
    
}

extension CachedViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let imageSize = images[indexPath.row].size
        return CGSize(width: 160, height: (160/imageSize.width) * imageSize.height);
    }
}
