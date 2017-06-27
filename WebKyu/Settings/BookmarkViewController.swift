//
//  BookmarkViewController.swift
//  WebKyu
//
//  Created by yan on 2017/06/22.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit
import MBProgressHUD
import Kingfisher



class BookmarkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var bookmarks: [Bookmark]!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bookmarks = BookmarkManager.shared.bookmarks
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addBookmark(_ sender: Any) {
        let alert = UIAlertController(title: "URL", message: "Add a bookmark", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.URL
            textField.placeholder = "input bookmark url"
            textField.returnKeyType = UIReturnKeyType.done
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in

        }))
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (_) in
            guard let textField = alert.textFields?.first else { return }
            guard var text = textField.text else { return }

            if !text.hasPrefix("http://") || !text.hasPrefix("https://") {
                text = "http://" + text
            }

            guard let url = URL(string: text) else {
                //
                self.show(errorMessage: "Invalid url")
                return
            }

            guard self.bookmarks.first(where: { $0.url == url }) == nil else {
                self.show(errorMessage: "Repeat url")
                return
            }

            self.fetchFavIcon(forUrl: url, withCompletion: { (favIconUrl) in
                let bookmark = Bookmark(url: url, favIconUrl: favIconUrl)
                let count = self.bookmarks.count
                self.bookmarks.append(bookmark)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: count, section: 0)],
                                          with: UITableViewRowAnimation.automatic)
                self.tableView.endUpdates()
                self.persistentBookmarks()
            })
        }))
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func editBookmarks(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    private func persistentBookmarks() {
        DispatchQueue.global(qos: .background).async {
            BookmarkManager.shared.bookmarks = self.bookmarks
        }
    }

    private func show(errorMessage: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = errorMessage
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 1.5)
    }

    private func fetchFavIcon(forUrl url: URL, withCompletion: @escaping (_ favIconUrl: URL?) -> Void) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.show(animated: true)

        do {
            try FavIcon.scan(url.absoluteString, completion: { (icons) in
                guard let icon = FavIcon.chooseIcon(icons) else {
                    DispatchQueue.main.async {
                        withCompletion(nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    withCompletion(icon.url)
                }
                hud.hide(animated: true)
            })
            /*
            try FavIcon.downloadPreferred(url) { (result) in
                switch (result) {
                case .success(let image):
                    hud.mode = MBProgressHUDMode.customView
                    hud.customView = UIImageView(image: image)
                    hud.hide(animated: true, afterDelay: 1.5)
                case .failure(let error):
                }
            }*/
        } catch {
            hud.mode = MBProgressHUDMode.text
            hud.label.numberOfLines = 0
            hud.label.text = "Error: \(error)"
            hud.hide(animated: true, afterDelay: 1.5)
        }
    }
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmark", for: indexPath) as! BookmarkTableViewCell
        let bookmark = self.bookmarks[indexPath.row]


        cell.titleLabel?.text = bookmark.url.absoluteString
        if let favIconUrl = bookmark.favIconUrl {
            cell.favIconImageView?.kf.setImage(with: ImageResource(downloadURL: favIconUrl))
        } else {
            cell.favIconImageView?.image = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.persistentBookmarks()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        swap(&bookmarks[fromIndexPath.row], &bookmarks[to.row])
        self.persistentBookmarks()
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
