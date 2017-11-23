//
//  ViewController.swift
//  Pandora Desktop
//
//  Created by Poul Hornsleth on 11/18/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        if let url = URL(string: "https://www.hackingwithswift.com")
        {
            print( "requesting \(url)")
            let request = URLRequest(url: url)
            webView.load(request)
            
        }
        else
        {
            print("bad url ")
        }

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var webView: WKWebView!
}

extension ViewController: WKUIDelegate
{
    override func loadView() {
        super.loadView()
//super.loadView()
        print("loadod")
    }
    
}

extension ViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("challenge")
    }
    
}
