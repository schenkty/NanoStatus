//
//  AppDelegate.swift
//  RaiMoon
//
//  Created by Danny Tatom on 12/28/17.
//  Copyright © 2017 Danny Tatom. All rights reserved.
//

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    
    var item : NSStatusItem? = nil
    
    var btc : NSMenuItem? = nil
    var percentChange1h : NSMenuItem? = nil
    var percentChange24h : NSMenuItem? = nil
    var percentChange7d : NSMenuItem? = nil
    var marketCap : NSMenuItem? = nil
    var rank : NSMenuItem? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        item?.title = "Fetching price..."
        
        btc = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange1h = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange24h = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange7d = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        marketCap = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        rank = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        
        let menu = NSMenu()
        menu.addItem(btc!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(percentChange1h!)
        menu.addItem(percentChange24h!)
        menu.addItem(percentChange7d!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(marketCap!)
        menu.addItem(rank!)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Refresh Data", action: #selector(fetchPrice), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: ""))
        item?.menu = menu
        
        fetchPrice()
        
        // Pull every 5 mins. Data Source only updates every 5 mins
        Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(fetchPrice), userInfo: nil, repeats: true)
    }

    @objc func fetchPrice() {
        print("Fetching price...")
        
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/raiblocks/").responseJSON { response in
            if let data = response.result.value {
                if  (data as? [[String : AnyObject]]) != nil {
                    if let dictionaryArray = data as? Array<Dictionary<String, AnyObject?>> {
                        let usd = dictionaryArray[0]["price_usd"] as? String
                        
                        self.item?.title = "XRB: $\(usd ?? "???")"
                        
                        self.btc?.title = "\(dictionaryArray[0]["price_btc"] as? String ?? "???") BTC"
                        self.percentChange1h?.title = "1h: \(dictionaryArray[0]["percent_change_1h"] as? String ?? "???")%"
                        self.percentChange24h?.title = "24h: \(dictionaryArray[0]["percent_change_24h"] as? String ?? "???")%"
                        self.percentChange7d?.title = "7d: \(dictionaryArray[0]["percent_change_7d"] as? String ?? "???")%"
                        self.marketCap?.title = "Market Cap: $\(dictionaryArray[0]["market_cap_usd"] as? String ?? "???")"
                        self.rank?.title = "Rank: \(dictionaryArray[0]["rank"] as? String ?? "???")"
                    }
                }
            } else {
                let error = (response.result.value  as? [[String : AnyObject]])
                print(error as Any)
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
