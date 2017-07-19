//
//  SettingViewController.swift
//  WebKyu
//
//  Created by yan on 2017/02/28.
//  Copyright © 2017 mmd. All rights reserved.
//

import UIKit
import MessageUI
import MBProgressHUD

enum WKSettingType: CustomStringConvertible {
    /// browser
    case favoriteBookmark

    /// Help
    case howToUse
    case feedback
    case rate

    /// Information
    case eula
    case privacy

    var description: String {
        switch self {
        case .favoriteBookmark:
            return NSLocalizedString("Bookmark", comment: "")

        case .howToUse:
            return NSLocalizedString("Help", comment: "")
        case .feedback:
            return NSLocalizedString("Feedback", comment: "")
        case .rate:
            return NSLocalizedString("Rate", comment: "")

        case .eula:
            return NSLocalizedString("EULA", comment: "")
        case .privacy:
            return NSLocalizedString("Privacy policy", comment: "")
        }
    }
}

enum WKSOptionAccessoryType: Int {
    case none
    case disclosureIndicator
}

struct WKSSection {
    let section: String?
    let options: [WKSOption]
    let footer: String?

    init(section: String? = nil, options: [WKSOption], footer: String? = nil) {
        self.section = section
        self.options = options
        self.footer = footer
    }
}

struct WKSOption {
    var type: WKSettingType
    var accessoryType: WKSOptionAccessoryType
    var tag: Int

    init(type: WKSettingType, accessoryType: WKSOptionAccessoryType = WKSOptionAccessoryType.none, tag: Int = -1) {
        self.type = type
        self.accessoryType = accessoryType
        self.tag = tag
    }
}

func appVersion() -> String {
    let dict = Bundle.main.infoDictionary!
    return "Ver \(dict["CFBundleShortVersionString"]!) (\(dict["CFBundleVersion"]!))"
}

class SettingViewController: UIViewController {

    fileprivate let settingSource: [WKSSection] = [
        WKSSection(section: NSLocalizedString("Browser", comment: ""),
                   options: [ WKSOption(type: .favoriteBookmark, accessoryType: .disclosureIndicator)],
                   footer: nil),
        WKSSection(section: NSLocalizedString("Help", comment: ""),
                   options: [ WKSOption(type: .feedback, accessoryType: .disclosureIndicator),
                              WKSOption(type: .rate, accessoryType: .disclosureIndicator), ],
                   footer: nil),
        WKSSection(section: NSLocalizedString("Info", comment: ""),
                   options: [ WKSOption(type: .eula, accessoryType: .disclosureIndicator),
                              WKSOption(type: .privacy, accessoryType: . disclosureIndicator), ],
                   footer: appVersion())
    ]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Setting", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hideSettings(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }

        if id == "showWebView" {
            guard let param = sender as? String else { return }

            let webViewController = segue.destination as! WebViewController
            webViewController.title = param
            webViewController.localUrl = Bundle.main.url(forResource: param, withExtension: "html")
        }
    }
}

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSource[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSource[section].section
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settingSource[section].footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let option = settingSource[indexPath.section].options[indexPath.row]

        cell.textLabel?.text = option.type.description
        if option.accessoryType == .disclosureIndicator {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let option = settingSource[indexPath.section].options[indexPath.row]

        switch option.type {
        case .favoriteBookmark:
            self.showFavoriteBookmarks()

        case .feedback:
            self.showFeedback()

        case .rate:
            self.showRate()

        case .eula:
            self.showEULA()

        case .privacy:
            self.showPrivacy()

        default:
            break
        }
    }

    func showFavoriteBookmarks() {
        self.performSegue(withIdentifier: "showBookmark", sender: nil)
    }

    func showFeedback() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Cannot open email", comment: "can't open email client"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        let mail = MFMailComposeViewController()
        mail.setSubject(NSLocalizedString("Feedback Title", comment: "feedback email title"))
        mail.setToRecipients(["feedback.mmd.dev@gmail.com"])
        // TODO: message body with saved function
        mail.setMessageBody("", isHTML: false)
        mail.mailComposeDelegate = self
        self.navigationController?.present(mail, animated: true, completion: {

        })
    }

    func showRate() {
        let appStoreUrl = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1253024518"
        if let url = URL(string: appStoreUrl){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }

    func showEULA() {
        self.performSegue(withIdentifier: "showWebView", sender: "eula")
    }

    func showPrivacy() {
        self.performSegue(withIdentifier: "showWebView", sender: "privacy")
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //@constant   MFMailComposeResultCancelled   User canceled the composition.
        //@constant   MFMailComposeResultSaved       User successfully saved the message.
        //@constant   MFMailComposeResultSent        User successfully sent/queued the message.
        //@constant   MFMailComposeResultFailed      User's attempt to save or send was unsuccessful.
        controller.dismiss(animated: true, completion: {
            if result == MFMailComposeResult.sent {
                let hudView = MBProgressHUD.showAdded(to: self.view, animated: true)
                hudView.mode = MBProgressHUDMode.text
                hudView.label.text = NSLocalizedString("Thanks for your advice", comment: "")
                hudView.show(animated: true)
                hudView.hide(animated: true, afterDelay: 3.0)
            }
        })
    }
}
