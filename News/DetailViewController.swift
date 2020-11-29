//
//  DetailViewController.swift
//  News
//
//  Created by Dmitry Reshetnik on 29.11.2020.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var detailItem: Response.Article?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard let detailItem = detailItem else { return }
        
        if detailItem.url != nil {
            let url = URL(string: detailItem.url!)!
            webView.load(URLRequest(url: url))
        } else {
            let html = """
                <html>
                <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                body { font-size: 150%; font-family: Geneva, Arial, Helvetica, sans-serif; margin-left: 15px; line-height: 1; text-indent: 25px;}
                </style>
                </head>
                <body>
                \(detailItem.content ?? "Error. No content available.")
                </body>
                </html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let back = UIBarButtonItem(title: "Back", style: .done, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(title: "Forward", style: .done, target: webView, action: #selector(webView.goForward))
        
        toolbarItems = [progressButton, spacer, refresh, back, forward]
        navigationController?.isToolbarHidden = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
