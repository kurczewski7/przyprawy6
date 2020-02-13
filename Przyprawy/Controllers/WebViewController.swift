//
//  WebViewController.swift
//  Przyprawy
//
//  Created by Slawek Kurczewski on 07/02/2019.
//  Copyright © 2019 Slawomir Kurczewski. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WebCreatorDelegate {
    var telFrom   = ["512589528"]
    var emailFrom = ["kurczewski7@gmail.com","test@gmail.com"]

    var webView: WKWebView!
    var html: String = ""
    var sms:  String = ""
    var webCreator: WebCreator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.loadData(tableNameType: .toShop)
        prepareDataForWeb()
        webCreator = WebCreator(polishLanguage: Setup.polishLanguage, telFrom: telFrom, emailFrom: emailFrom)
        webCreator.delegate = self
        webCreator.generateHtml()

        displayHtml()
        displaySms()
    }
    override func viewWillAppear(_ animated: Bool) {
        prepareDataForWeb()
    }
    func prepareDataForWeb() {
             let numList=Setup.currentListNumber+1
             database.loadData(tableNameType: .toShop)
             database.category.crateCategoryGroups(forToShopProduct: database.toShopProduct.array)
             self.title=cards[0].getName()+" \(numList)"
         }
     // MARK: WebCreatorDelegate method
     func webCreatorDataSource(forRow row: Int, forSection section: Int) -> ProductTable? {
         let  prodNumber=database.category.sectionsData[section].objects[row]
         let product = database.toShopProduct[prodNumber].productRelation
         return product
     }
     func webCreatorNumberOfRows(forSection section: Int) -> Int {
         let xxx = database.category.getCurrentSectionCount(forSection: section)
         print("xxx:\(xxx)")
         return  database.category.getCurrentSectionCount(forSection: section)
     }
     func webCreatorNumberOfSections() -> Int {
         let yyy = database.category.getTotalNumberOfSection()
         print("xxx:\(yyy)")
         return  database.category.getTotalNumberOfSection()
     }
     func webCreatorHeaderForSection() -> [String]? {
        var titleInfo = [String]()
        let sectionCount = webCreatorNumberOfSections()
        for i in 0..<sectionCount {
             let sectionName = database.category.getCategorySectionHeader(forSection: i)
             titleInfo.append(sectionName)
        }
        return titleInfo
     }
    // End of WebCreatorDelegate
 
    func displaySms() {
        sms = webCreator.getFullSms(myPhoneNumber: telFrom, myEmail: emailFrom)
    }
    func displayHtml() {
        html = webCreator.getFullHtml()
        
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[webView]-|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil, views: ["webView": webView!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[webView]-|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil, views: ["webView": webView!]))
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.loadHTMLString(html, baseURL: nil)
        // Do any additional setup after loading the view.
        saveToPdf()
        createPdfFromView(aView: webView, saveToDocumentsWithFileName: "PdfFile2.pdf")
    }
    func saveToPdf() {
        //let web = 
        //webView
        let fileName = "PdfData.pdf"
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, webView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        webView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String) {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="gotoShare"
        {
            let nextController=segue.destination as! ShareViewController
            nextController.htmlText = html
            nextController.smsText  = sms
        }
    }
}
