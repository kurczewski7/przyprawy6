//
//  Contacts.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 24.08.2018.
//  Copyright © 2018 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class Contacts: UIViewController, ListenSpeechDelegate {
    var listenSpeech: ListenSpeech!

    override func viewDidAppear(_ animated: Bool) {
        listenSpeech = ListenSpeech()
        listenSpeech?.delegate = self
        print("")
    }
    override func viewDidDisappear(_ animated: Bool) {
        listenSpeech = nil
    }
    // MARK: mothod for protocol ListenSpeechDelegate
    func updateListenSpeechInterface(forRedyToRecord isReady: Bool) {
        let ikonName = isReady ? "circled_pause" : "microphone"
        navigationItem.leftBarButtonItem?.image = UIImage(named: ikonName)
        navigationItem.leftBarButtonItem?.tintColor =  isReady ? .systemRed : .systemBlue
    }
    @IBAction func speeakTest() {
        let speeking = Speaking()
        listenSpeech.didTapRecordButton()
        if listenSpeech.isRecordEnabled {
            if !listenSpeech.isEmpty {
                print("\(listenSpeech.recordedMessage)")
                Setup.currentLanguage = .polish
                speeking.textToSpeach = "To jest test rozpoznania mowy" //listenSpeech.recordedMessage
            }
        }
        print("Message: \(listenSpeech.recordedMessage), \(listenSpeech.isRecordEnabled)")
     }
    @IBAction func callAction(_ sender: Any) {
        var tel = "512 58 95 28"
        tel=tel.replacingOccurrences(of: " ", with: "")
        print(tel)
        openMyUrl(with: "tel://\(tel)")
     }    
    @IBAction func emailAction(_ sender: UIButton) {
        // let email2 = "mailto:kurczewski7@gmail.com?cc=kurczewsscy@gmail.com&subject=Greetings%20from%20Cupertino!&body=Wish%20you%20were%20here!"
        
        let email = "kurczewski7@gmail.com"
        let cc = "kurczewscy@gmail.com"
        let subject = "E-mail test from iphone"
        let body = "Test <b>sending e-mail</b> by Sławomir \nKurczewski, łódź, śróba, żywiec"
        
        let orginalEmail = "mailto://\(email)?cc=\(cc)&subject=\(subject)&body=\(body)"
        if  let encodedEmail = orginalEmail.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        {
            print(encodedEmail)
            openMyUrl(with: encodedEmail)
        }
    }
    @IBAction func smsButton(_ sender: Any) {
        let sms=512589528
        print(sms)
        openMyUrl(with: "sms://\(sms)")
    }
    @IBAction func contactsActions(_ sender: Any) {
    }
    @IBAction func rewindToContacts(segue:UIStoryboardSegue) {
    
    }
    private func openMyUrl(with myStringUrl: String)
    {
        guard let url=URL(string: myStringUrl)    else {
                return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

