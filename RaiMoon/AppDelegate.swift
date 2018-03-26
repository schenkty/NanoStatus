//
//  AppDelegate.swift
//  RaiMoon
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    
    var item: NSStatusItem? = nil
    var btc: NSMenuItem? = nil
    var percentChange1h: NSMenuItem? = nil
    var percentChange24h: NSMenuItem? = nil
    var percentChange7d: NSMenuItem? = nil
    var marketCap: NSMenuItem? = nil
    var rank: NSMenuItem? = nil
    var updated: NSMenuItem? = nil
    
    var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        item?.title = "Fetching price..."
        
        btc = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange1h = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange24h = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        percentChange7d = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        marketCap = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        rank = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        updated = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Developer: Ty Schenk", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: ""))
        item?.menu = menu
        
        refreshPrice()
        
        // Pull every 5 mins. Data Source only updates every 5 mins
        Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(fetchPrice), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(refreshPrice), userInfo: nil, repeats: true)
    }
    
    @objc func refreshPrice() {
        if Connectivity.isConnectedToInternet {
            if item?.title == "Fetching price..." {
                fetchPrice()
            }
        } else {
            return
        }
    }

    @objc func fetchPrice() {
        if !Connectivity.isConnectedToInternet {
            return
        }
        
        Alamofire.request("https://api.coinmarketcap.com/v1/ticker/nano/").responseJSON { response in
            if let data = response.result.value {
                if  (data as? [[String : AnyObject]]) != nil {
                    if let dictionaryArray = data as? Array<Dictionary<String, AnyObject?>> {
                        self.item?.menu = NSMenu()
                        
                        let usd = dictionaryArray[0]["price_usd"] as? String ?? "0.00"
                        let symbol = dictionaryArray[0]["name"] as? String
                        
                        self.item?.title = "\(symbol ?? "-"): \(self.formatCurrency(value: Double(usd)!))"
                        
                        self.btc?.title = "\(dictionaryArray[0]["price_btc"] as? String ?? "???") BTC"
                        self.percentChange1h?.title = "1h: \(dictionaryArray[0]["percent_change_1h"] as? String ?? "???")%"
                        self.percentChange24h?.title = "24h: \(dictionaryArray[0]["percent_change_24h"] as? String ?? "???")%"
                        self.percentChange7d?.title = "7d: \(dictionaryArray[0]["percent_change_7d"] as? String ?? "???")%"
                        self.rank?.title = "Rank: \(dictionaryArray[0]["rank"] as? String ?? "???")"
                        
                        let mcString = dictionaryArray[0]["market_cap_usd"] as? String ?? "0.0"
                        let mc = Double(mcString)!
                        self.marketCap?.title = "Market Cap: \(self.formatCurrency(value: mc))"
                        
                        let updated = dictionaryArray[0]["last_updated"] as? String ?? "1514764800"
                        let stamp = Double(updated)!
                        let date = Date(timeIntervalSince1970: stamp)
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone(abbreviation: self.localTimeZoneAbbreviation)
                        dateFormatter.locale = NSLocale.current
                        dateFormatter.dateFormat = "M/dd/yyyy HH:mm a"
                        let strDate = dateFormatter.string(from: date)
                        self.updated?.title = "Updated: \(strDate)"
                        
                        let menu = NSMenu()
                        menu.addItem(self.btc!)
                        menu.addItem(NSMenuItem.separator())
                        menu.addItem(self.percentChange1h!)
                        menu.addItem(self.percentChange24h!)
                        menu.addItem(self.percentChange7d!)
                        menu.addItem(NSMenuItem.separator())
                        menu.addItem(self.marketCap!)
                        menu.addItem(self.rank!)
                        menu.addItem(NSMenuItem.separator())
                        menu.addItem(self.updated!)
                        menu.addItem(NSMenuItem.separator())
                        menu.addItem(NSMenuItem(title: "Developer: Ty Schenk", action: nil, keyEquivalent: ""))
                        menu.addItem(NSMenuItem.separator())
                        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: ""))
                        self.item?.menu = menu
                    }
                }
            } else {
                let error = (response.result.value  as? [[String : AnyObject]])
                print("data pull failed")
                print(error as Any)
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: Check Network
    class Connectivity {
        class var isConnectedToInternet:Bool {
            return NetworkReachabilityManager()!.isReachable
        }
    }
    
    func formatCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: value as NSNumber)
        return result!
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
