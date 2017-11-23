//
//  RiskView.swift
//  P3Software
//
//  Created by Poul Hornsleth on 11/9/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Foundation
func diagnose<T>(file: String = #file, line: Int = #line) -> T? {
    print("Testing \(file):\(line)")
    return nil
}
class RiskView: NSObject {
    
    class Account
    {
        init?( json: [String:Any] )
        {            
            guard let positionLimit = json["position_limit"] as? Int ?? diagnose(),
            let grossLimit = json["gross_limit"] as? Int ?? diagnose(),
            let netFees = json["net_fees"] as? Float ?? diagnose(),
            let openPosition = json["open_position"] as? Int ?? diagnose(),
            let shortPosition = json["short_position"] as? Int ?? diagnose(),
            let openOrders = json["open_orders"] as? Int ?? diagnose(),
            let stratGroup = json["strat_group"] as? String ?? diagnose(),
            let totalPnl = json["total_pnl"] as? Int ?? diagnose(),
            let grossPosition = json["gross_position"] as? Int ?? diagnose(),
            let id = json["id"] as? Int ?? diagnose(),
            let longPosition = json["long_position"] as? Int ?? diagnose(),
            let account = json["account"] as? String ?? diagnose(),
            let totalShares = json["total_shares"] as? Int ?? diagnose()
                else {
                    return nil
            }
            
            self.positionLimit = positionLimit
            self.grossLimit = grossLimit
            self.netFees = netFees
            self.openPosition = openPosition
            self.shortPosition = shortPosition
            self.openOrders = openOrders
            self.stratGroup = stratGroup
            self.totalPnl = totalPnl
            self.grossPosition = grossPosition
            self.id = id
            self.longPosition = longPosition
            self.account = account
            self.totalShares = totalShares
        }
       
        let positionLimit : Int
        let grossLimit : Int
        let netFees : Float
        let openPosition : Int
        let shortPosition : Int
        let openOrders : Int
        let stratGroup : String
        let totalPnl : Int
        let grossPosition : Int
        let id : Int
        let longPosition : Int
        let account : String
        let totalShares : Int
    }
    
    class Instrument
    {
        init?( json:[String:Any] )
        {
            guard let id = json["id"] as? String ?? diagnose(),
                let instrument = json["instrument"] as? String ?? diagnose(),
                let shares = json["shares"] as? Int ?? diagnose(),
                let totalPnl = json["total_pnl"] as? Float ?? diagnose(),
                let netFees = json["net_fees"] as? Double ?? diagnose(),
                let totalShares = json["total_shares"] as? Int ?? diagnose(),
                let positionLimit = json["position_limit"] as? Int ?? diagnose(),
                let exposureLimit = json["exposure_limit"] as? Int ?? diagnose(),
                let totalVolume = json["total_volume"] as? Int ?? diagnose(),
                let lastTickUpdateTime = json["last_tick_update_time"] as? Float ?? diagnose(),
                let isClose = json["is_close"] as? Bool ?? diagnose(),
                let lastTick = json["last_tick"] as? Float ?? diagnose(),
                let prevClose = json["prev_close"] as? Float ?? diagnose()
                else {
                    return nil
            }
            
            self.id = id
            self.instrument = instrument
            self.shares = shares
            self.totalPnl = totalPnl
            self.netFees = netFees
            self.totalShares = totalShares
            self.positionLimit = positionLimit
            self.exposureLimit = exposureLimit
            self.totalVolume = totalVolume
            self.lastTickUpdateTime = lastTickUpdateTime
            self.isClose = isClose
            self.lastTick = lastTick
            self.prevClose = prevClose
        }
        
        let id : String
        let instrument : String
        let shares : Int
        let totalPnl : Float
        let netFees : Double
        let totalShares : Int
        let positionLimit : Int
        let exposureLimit : Int
        let totalVolume : Int
        let lastTickUpdateTime : Float
        let isClose : Bool
        let lastTick : Float
        let prevClose : Float
    }
    
   // static let INTERNAL_GATEWAY = URL( string: "")
    static let GATEWAY = URL( string: "https://www.athenacr.com:443/gateway")
    static let ASIA = "asiariskview/risk/accounts"
    static let US = "usriskview/risk/accounts"
    
   // static let INTERNAL_URL = URL( string: "https://risk.in.athenacr.com/acr/riskview/risk/accounts" )
    let url : URL
    var session : URLSession
    var loginProtectionSpace : URLProtectionSpace
    var region : String?
    
    init?( urlSessionDelegate : URLSessionDelegate )
    {
        print("new riskview")
        guard let url = RiskView.GATEWAY,
        let host = url.host,
        let port = url.port,
        let scheme = url.scheme
            else {
                return nil
        }
       
        self.url = url
        
        self.loginProtectionSpace = URLProtectionSpace(host: host, port: port, protocol: scheme, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: urlSessionDelegate, delegateQueue: nil)
    }
    
    func setRegion( region : String )
    {
        self.region = region
    }
    
    func clearCredential()
    {
        guard let credential = self.getCredential()
            else {
                return
        }
        URLCredentialStorage.shared.remove( credential, for: self.loginProtectionSpace )
    }
    func getCredential() -> URLCredential?
    {
        
        return URLCredentialStorage.shared.defaultCredential(for: self.loginProtectionSpace)
//        URLCredentialStorage.shared.getDefaultCredential(for: <#T##URLProtectionSpace#>, task: <#T##URLSessionTask#>, completionHandler: <#T##(URLCredential?) -> Void#>)
//        print("getCredential")
//        if let credDict = URLCredentialStorage.shared.credentials(for: self.loginProtectionSpace )
//        {
//            print( credDict )
//            for (_, credential) in credDict
//            {
//                return credential
//            }
//        }
//        print("no dict")
//        return nil
       // URLCredentialStorage.shared.credentials(for: self.riskView!.loginProtectionSpace)
    }
    
    func setCredential( credential: URLCredential)
    {
        print("setting Credential \(credential.user!)")
        URLCredentialStorage.shared.setDefaultCredential(credential, for: self.loginProtectionSpace)
    }
    
    
    func getUsernamePassword() -> ( String, String )?
    {
        if let credDict = URLCredentialStorage.shared.credentials(for: self.loginProtectionSpace)
        {
            for ( _,credential ) in credDict
            {
                if let username = credential.user,
                    let password = credential.password
                {
                    return ( username, password )
                }
            }
        }
        return nil
    }
    
    func fetch( url: URL, callback: @escaping (Bool,Data?)-> () ) {
        var request = URLRequest.init( url: url )
        
        request.httpMethod = "GET"
        
        let task = self.session.dataTask(with: request) { ( data, response, error ) in
            if error != nil {
                
                callback(false,nil)
                return

            } else {
                if let binary = data {
                    callback( true, binary )
                    return
                }
            }
            callback( false, nil )
        }
        
        task.resume()
    }
    
    func fetchJSON( url: URL, callback: @escaping (Bool,[String:Any])-> () ) {
        print( url )
        self.fetch( url: url, callback: { ( success: Bool, data: Data? ) -> () in
            do
            {
                if( success )
                {
                    guard let theData = data
                        else {
                            callback( false,[:])
                            return
                    }
                    // let s = String( data:data, encoding:String.Encoding.utf8)
                    // print( s! )
                    
                    let obj = try JSONSerialization.jsonObject(with: theData) as! [String: Any]
                    callback( true,obj )
                    return
                }
                callback( false, [:])
            }
            catch
            {
                print("caught: \(error)")
            }
        })
        
    }
    
    func fetchAccounts( callback: @escaping (Bool, [ String : [RiskView.Account] ])-> () )
    {
        guard let region = self.region
            else {
                callback( false, [:] )
                return
        }
        self.fetchJSON(url: self.url.appendingPathComponent( region )) { ( success: Bool, json:[String:Any]) in
            
            if( !success )
            {
                callback(false,[:])
                return
            }
            
            guard let accounts = json["accounts"] as? [ [String:Any]]
                else {
                    
                    callback(false,[:])
                    return
            }
            
            var rval : [ String : [RiskView.Account] ] = [:]
            for account in accounts
            {
                if let a = RiskView.Account( json:account )
                {
                //    print( a.stratGroup)
                    if( rval[ a.stratGroup] == nil)
                    {
                        rval[ a.stratGroup ] = []
                    }
                    if var accounts = rval[ a.stratGroup ]
                    {
                        accounts.append(a)
                        rval[ a.stratGroup ] = accounts
                    }
                }
                else
                {
                    print("bad account")
                }
            }
            callback( true, rval )
        }
    }
    
    func fetchInstruments( forAccount: String, callback: @escaping (Bool,[RiskView.Instrument])-> () )
    {
        guard let region = self.region
            else {
                print("no region")
                callback( false, [] )
                return
        }
        
        self.fetchJSON(url: self.url.appendingPathComponent( region ).appendingPathComponent(forAccount)) { (success: Bool, json:[String:Any]) in

            if(!success)
            {
                print("no success")
                callback(false,[])
                return
            }
            guard let instruments = json["instruments"] as? [ [String:Any]]
                else {
                    print("no insturment")
                    callback(false,[])
                    return
            }
            
            var rval : [ RiskView.Instrument] = []
            for instrument in instruments
            {
                if let instr = RiskView.Instrument( json:instrument )
                {
                    rval.append( instr )
                }
            }
        
            callback( true,rval )
        }
    }
}


