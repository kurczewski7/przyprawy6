//
//  ShareViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 14/02/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import MessageUI
protocol ShareViewControllerDelegate {
    
}
class ShareViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    let emailAdressList = ["",""]
    let smsPhoneList = ["512589528","515914171"]
    
    var htmlText = ""
    var smsText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //sendSMS(with: smsText)
        //sendEmail(with: htmlText)
        
    }
    @IBAction func ShareSms(_ sender: Any) {
        //sendSMS(with: smsText)
    }
    @IBAction func ShareButton(_ sender: Any) {
       // sendEmail(with: htmlText)
    }
    
    @IBAction func eMailButtonTap(_ sender: UIButton) {
        sendEmail(with: htmlText)
    }
    
    @IBAction func smsButtonTap(_ sender: UIButton) {
        sendSMS(with: smsText)
    }
    
    @IBAction func phoneButtonTap(_ sender: UIButton) {
        var tel = smsPhoneList[0]
        tel=tel.replacingOccurrences(of: " ", with: "")
        openMyUrl(with: "telprompt://\(tel)")
    }
    
    @IBAction func contactButtonTap(_ sender: UIButton) {
    }
    //------------------- eMail ------
    func sendEmail(with html: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["kurczewski7@gmail.com","slawomir.kurczewski@gmail.com"])
            mail.setSubject("setSubject: Przyprawy")
            mail.setMessageBody(html, isHTML: true)
            present(mail, animated: true)
        } else {
           print("Error eMail send")
        }
    }
       func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
           switch result {
           case .sent:
                print("OK")
           case .cancelled:
                print("cancel")
           case .failed:
                print("error")
           case .saved:
                print("saved")
           default: break
           }
           controller.dismiss(animated: true)
       }
    //--------------- SMS -----
    func sendSMS(with text: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageSms = MFMessageComposeViewController()
            let urlString = """
            https://www.google.com/search?q=przyprawy&sxsrf=ACYBGNQ0Bo-yuunOyc4te6g0wto8bR70Hw:1579012459840&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjp447mp4PnAhWOjYsKHXsGBBIQ_AUoAXoECBQQAw&biw=1881&bih=895#imgrc=Jiw8CH4_k032VM:
            """
            messageSms.messageComposeDelegate = self
            messageSms.body = text
            messageSms.recipients = smsPhoneList
            messageSms.addAttachmentURL(URL(fileURLWithPath: urlString), withAlternateFilename: "http://www.gogle.com")
            present(messageSms, animated: true, completion: nil)
        }
    }
func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    
    switch result {
    case .sent:
        print("OK")
    case .cancelled:
        print("cancel")
    case .failed:
        print("error")
    default:
        break
    }
    controller.dismiss(animated: true)
}
    private func openMyUrl(with myStringUrl: String)
    {
        guard let url=URL(string: myStringUrl)    else {    return    }
        if #available(iOS 10.0, *) {
            let app: UIApplication = UIApplication.shared
            if app.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    app.open(url, options: [:], completionHandler: nil)
                }
                else {
                    app.openURL(url as URL)
                }
           }
        }
    }
//    if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
//
//        let application:UIApplication = UIApplication.shared
//        if (application.canOpenURL(phoneCallURL)) {
//            if #available(iOS 10.0, *) {
//                application.open(phoneCallURL, options: [:], completionHandler: nil)
//            } else {
//                // Fallback on earlier versions
//                 application.openURL(phoneCallURL as URL)
//
//            }
//        }
//    }
    
    
//    func sendSMS(with text: String) {
//        if MFMessageComposeViewController.canSendText() {
//            let messageComposeViewController = MFMessageComposeViewController()
//            messageComposeViewController.body = text
//            //messageComposeViewController.addAttachmentURL("www.coogle.com", withAlternateFilename: "http://www.gogle.com")
//            present(messageComposeViewController, animated: true, completion: nil)
//        }
//    }
}
