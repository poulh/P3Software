//
//  MasterViewController.swift
//  RiskView
//
//  Created by Poul Hornsleth on 11/9/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    @IBOutlet weak var accountTableView: UITableView!
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var riskView : RiskView?
    var accounts : [ String : [RiskView.Account] ] = [:]
    
    var stratGroups : [String] = []
    override func viewDidLoad()
    {
        self.riskView = RiskView(urlSessionDelegate: self)
        
        super.viewDidLoad()
       
    }
    
    func fetchAccountData()
    {
        guard let riskView = self.riskView
            else {
                return
        }
        
        if( riskView.getCredential() == nil )
        {
            doLoginAlert(persistence: URLCredential.Persistence.forSession, callback: { ( credential: URLCredential, region:String ) in
                
                riskView.setCredential( credential: credential )
                riskView.setRegion(region: region )
                self.fetchAccountData()
            })
            return
        }
        
        riskView.fetchAccounts( callback: { ( success: Bool, accounts : [String : [RiskView.Account] ] ) -> () in
            
            DispatchQueue.main.async() {
                if(success)
                {
                    self.accounts = accounts
                    self.stratGroups = []
                    
                    for ( stratGroup, _) in self.accounts
                    {
                        self.stratGroups.append(stratGroup)
                    }
                    self.stratGroups.sort()
                    self.accountTableView.reloadData()
                }
                else
                {
                    riskView.clearCredential()
                    self.fetchAccountData()
                }
            }
        })
    }

    func doLoginAlert( persistence: URLCredential.Persistence, callback: @escaping (URLCredential,String) ->() )
    {
        let alert = UIAlertController(title: "RiskView Login",
                                      message: "Please Enter Your Login Information",
                                      preferredStyle: .alert)

        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = UITextAutocorrectionType.no
            textField.placeholder = "Username"
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = UITextAutocorrectionType.no
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: "Login US", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            if let textFields = alert.textFields
            {
                let usernameField = textFields[0]
                let passwordField = textFields[1]

                let credential = URLCredential(user: usernameField.text!, password: passwordField.text!, persistence: persistence)
                
                callback( credential, RiskView.US )
                // URLCredential.Persistence.forSession
            }
        })
        
        let loginAsiaAction = UIAlertAction(title: "Login To Asia", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            if let textFields = alert.textFields
            {
                let usernameField = textFields[0]
                let passwordField = textFields[1]

                let credential = URLCredential(user: usernameField.text!, password: passwordField.text!, persistence: persistence)
                
                callback( credential, RiskView.ASIA )
            }
        })
        
        // Add action buttons and present the Alert
        alert.addAction(loginAction)
        alert.addAction(loginAsiaAction)

        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        self.fetchAccountData()

        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let stratGroup = self.stratGroups[ indexPath.section ]
                guard let accounts = self.accounts[ stratGroup ]
                    else {
                        return
                }
                
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.riskView = self.riskView
                controller.account = accounts[ indexPath.row]
                controller.navigationItem.title = accounts[ indexPath.row].account
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                //  let object = objects[indexPath.row] as! NSDate
                
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.stratGroups.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let tableHeaderView = view as? UITableViewHeaderFooterView {
            tableHeaderView.textLabel?.textColor = UIColor.lightGray
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stratGroup = self.stratGroups[ section ]
        if let accounts = self.accounts[ stratGroup ]
        {
            return accounts.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let stratGroup = self.stratGroups[ section ]
        var sum = 0.0
        if let accounts = self.accounts[ stratGroup ]
        {
            let pnls = accounts.map({ (account:RiskView.Account) -> Int in
                return account.totalPnl
            })
            
            for pnl in pnls
            {
                sum = sum + Double(pnl)
            }
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:sum))
        let sg = stratGroup.replacingOccurrences(of: "_", with: " ").capitalized
        return String(format: "\(sg): \(formattedNumber!)")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let stratGroup = self.stratGroups[ indexPath.section ]

        if let accounts = self.accounts[ stratGroup ]
        {
            let account = accounts[ indexPath.row ]
            let pnl = account.totalPnl
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:pnl))
            let text = "\(account.account): \(formattedNumber!)"
            cell.textLabel!.text = text
            cell.backgroundColor = UIColor.black
            cell.textLabel!.textColor = pnl < 0 ? UIColor.red : UIColor.green
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    var challenges = 0
}
  

extension MasterViewController : URLSessionTaskDelegate
{
    func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didReceive challenge: URLAuthenticationChallenge,
                             completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        self.challenges = self.challenges + 1
        print("challenge: \(self.challenges)")
        guard let riskView = self.riskView,
            let credential = riskView.getCredential()
            else {
                print("no credential")
                return
        }
        if( self.challenges > 2 )
        {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, credential)

        }
        else
        {
            print("too many challenges")
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)
    {
        print("did finish metrics \(self.challenges)")
//        if( self.challenges > 2)
//        {
//            self.doLoginAlert(persistence: URLCredential.Persistence.forSession, callback: { (credential:URLCredential, region:String) in
//                if let riskView = self.riskView
//                {
//                    riskView.setCredential(credential: credential)
//                    riskView.setRegion(region: region )
//                }
//            })
//        }
        self.challenges = 0
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        print("did finish error")
    }
    
    
}



