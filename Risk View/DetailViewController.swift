//
//  DetailViewController.swift
//  Risk View 2
//
//  Created by Poul Hornsleth on 11/20/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var instrumentTableView: UITableView!

    var riskView : RiskView?
    var instruments : [RiskView.Instrument] = []
    
    func configureView()
    {
        guard let riskView = self.riskView,
        let account = self.account
            else {                
                return
        }
        
        riskView.fetchInstruments( forAccount: account.account, callback: { (success: Bool, instruments:[RiskView.Instrument]) in
            DispatchQueue.main.async() {
                if( success )
                {
                    self.instruments = instruments
                    
                    self.instruments.sort(by: { (lhs : RiskView.Instrument, rhs : RiskView.Instrument ) -> Bool in
                        
                        return abs( rhs.totalPnl ) < abs( lhs.totalPnl )
                    })
                    self.instrumentTableView.reloadData()
                }
                else
                {
                    print("no success")
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var account: RiskView.Account? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.instruments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Instrument Cell", for: indexPath)
        let instrument = self.instruments[ indexPath.row ]
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:instrument.totalPnl))
        cell.textLabel!.text = "\(instrument.instrument): \(formattedNumber!)"
        cell.textLabel!.textColor = instrument.totalPnl < 0 ? UIColor.red : UIColor.green
 
        return cell
    }


}

