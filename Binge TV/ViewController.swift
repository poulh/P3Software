//
//  ViewController.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/2/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa
import NetworkExtension

class ViewController: NSViewController {
    
    @IBOutlet weak var seriesTableView: NSTableView!
    @IBOutlet weak var episodesTableView: NSTableView!
    @IBOutlet weak var downloadsTableView: NSTableView!
    
    @IBOutlet weak var seriesLabel: NSTextField!
    @IBOutlet weak var downloadsLabel: NSTextField!
    
    //models
    var series: [TVDB.Series] = []
    var episodes: [String] = []
    var searchResults: [TVDB.Result] = []
    var episodeFiles : [ DownloadsManager.EpisodeFile ] = []
    var displaySearchResults = false
    
    // view helpers
    let seasonGroupingHelper = SeasonGroupingHelper()
    var seriesColorAnalyzer : ColorAnalyzer?
    let mediaDirectoryHelper = MediaDirectoryHelper()
    
    //data fetchers
    let userDefaults = UserDefaults.standard
    var tvdb: TVDB?
    var eztv: EZTV?
    var transmission: Transmission?
    var downloadsManager: DownloadsManager?
    
    var window : NSWindow?
    {
        get {
            if let win = self.view.window
            {
                return win
            }
            return nil
        }
    }
    var windowController : WindowController?
    {
        get {
            if let win = self.window
            {
                if let wc = win.windowController as? WindowController
                {
                    return wc
                }
            }
            return nil
        }
    }
    
    func getMediaDirectoryURL( mediaDirectoryURL: URL? ) -> [String:URL?]
    {
        let helper = MediaDirectoryHelper()
        if let url = mediaDirectoryURL
        {
            print( "url valid: \(url)")
            if let actualURL = helper.getActualURL( fromDisplayURL: url )
            {
                print( "actual \(actualURL)")
                return [ "display" : url, "actual" : actualURL ]
            }
        }
        
        var url : URL? = nil
        self.displayOpenPanel(window: self.window, title: "Please Select Media Directory") { (chosenURL: URL?) in
            url = chosenURL
        }

        if let u = url
        {
            print( u )
            let displayURL = helper.getDisplayURL(url: u)
            print( "display \(displayURL )" )
            return [ "display":displayURL, "actual":u ]
        }
        
        return ["display":nil,"actual":nil]
    }
    
    
  
    
    //    func doVpnStuff()
    //    {
    //        let manager = NEVPNManager.shared()
    //        manager.loadFromPreferences { (error:Error?) in
    //            if let e = error
    //            {
    //                print( "load error")
    //                print( e )
    //            }
    //            else
    //            {
    //                let p = NEVPNProtocolIPSec()
    //                p.username = "khiryj"
    //                p.serverAddress = "nyc1-ubuntu-l2tp.expressprovider.com"
    //                p.localIdentifier = "NYC Express VPN"
    //                p.remoteIdentifier = "New York2"
    //                p.disconnectOnSleep = false
    //                p.useExtendedAuthentication = false
    //                p.authenticationMethod  = NEVPNIKEAuthenticationMethod.sharedSecret
    //                p.sharedSecretReference = "12345678".data(using: String.Encoding.utf8)
    //                p.passwordReference = "h6b1amc4".data(using: String.Encoding.utf8)
    //              //  p.sharedSecretReference = ""
    //
    //               // p.passwordReference = ""
    //                manager.protocolConfiguration = p
    //                manager.localizedDescription = "Express Manager"
    //                manager.isOnDemandEnabled = true
    //                manager.saveToPreferences(completionHandler: { (error:Error?) in
    //                    if let e = error
    //                    {
    //                        print("save error")
    //                        print( e )
    //                    }
    //                    else
    //                    {
    //                        print( "saved?")
    //                    }
    //                })
    //
    //
    //
    //            }
    //        }
    
    /*
     NEVPNManager *manager = [NEVPNManager sharedManager];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnConnectionStatusChanged) name:NEVPNStatusDidChangeNotification object:nil];
     [manager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
     if(error) {
     NSLog(@"Load error: %@", error);
     }}];
     NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
     p.username = @“[My username]”;
     p.passwordReference = [KeyChainAccess loadDataForServiceNamed:@"VIT"];
     p.serverAddress = @“[My Server Address]“;
     p.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
     p.localIdentifier = @“[My Local identifier]”;
     p.remoteIdentifier = @“[My Remote identifier]”;
     p.useExtendedAuthentication = NO;
     p.identityData = [My VPN certification private key];
     p.disconnectOnSleep = NO;
     [manager setProtocol:p];
     [manager setOnDemandEnabled:NO];
     [manager setLocalizedDescription:@"VIT VPN"];
     NSArray *array = [NSArray new];
     [manager setOnDemandRules: array];
     NSLog(@"Connection desciption: %@", manager.localizedDescription);
     NSLog(@"VPN status:  %i", manager.connection.status);
     [manager saveToPreferencesWithCompletionHandler:^(NSError *error) {
     if(error) {
     NSLog(@"Save error: %@", error);
     }
     }];
     */
    
    
    func displayOpenPanel( window: NSWindow?, title: String, callback:@escaping (URL?)-> () )
    {
        let panel = NSOpenPanel()
        
        panel.title                   = title
        panel.showsResizeIndicator    = true
        panel.showsHiddenFiles        = false
        panel.canChooseDirectories    = true
        panel.canChooseFiles          = false
        panel.canCreateDirectories    = true
        panel.allowsMultipleSelection = false
        
        
//        if let win = window
//        {
//            print( "begin sheet")
//            panel.beginSheet( win, completionHandler: { (response:NSModalResponse) in
//
//            })
//        }
//        else
       // {
            print( "modal")
            if( panel.runModal() != NSApplication.ModalResponse.OK )
            {
                
            }
        //}
        
        if let url = panel.url
        {
            callback( url )
            return
        }
        callback( nil )
        return
    }
    
    func displayAlert( window: NSWindow?, message: String, buttonTitle: String,  callback:@escaping (Bool)-> () )
    {
        let alert = NSAlert()
        alert.addButton(withTitle:  buttonTitle )
        alert.alertStyle = NSAlert.Style.critical
        alert.messageText = message
        
        if let win = window
        {
            alert.beginSheetModal(for: win, completionHandler: { (response:NSApplication.ModalResponse) in
                if( response == NSApplication.ModalResponse.alertFirstButtonReturn )
                {
                    return callback( true )
                }
            })
        }
        else
        {
            if( alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn )
            {
                return callback( true )
            }
        }
        return callback( false )
    }
    
    override func viewWillAppear() {
        print(" view wil appear")
        super.viewWillAppear()
        self.seriesTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    override func viewDidLoad()
    {
        print("view did load")
        
        guard let defaultsPath = Bundle.main.path(forResource: "Defaults", ofType: "plist"),
            let defaultsProperties = NSDictionary(contentsOfFile: defaultsPath )
            else {
                displayAlert( window: self.window, message: "Could not load defaults file.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        guard let downloadsManagerDict = defaultsProperties.value( forKey: "Downloads Manager") as? NSDictionary,
            let videoExtensions = downloadsManagerDict.value( forKey: "Video Extensions" ) as? Array<String>,
            let subtitleExtensions = downloadsManagerDict.value( forKey: "Subtitle Extensions" ) as? Array<String>,
            let downloadRegexes = downloadsManagerDict.value( forKey: "Filename Regex" ) as? Array<String>,
            let mediaDirectoryName = downloadsManagerDict.value( forKey: "Media Directory Name" ) as? String,
            let tvdbDict = defaultsProperties.value(forKey: "TVDB") as? NSDictionary,
            let apiKey = tvdbDict.value( forKey: "API Key" ) as? String,
            let userKey = tvdbDict.value( forKey: "User Key" ) as? String,
            let userName = tvdbDict.value( forKey: "User Name" ) as? String,
            let transmissionDict = defaultsProperties.value( forKey: "Transmission" ) as? NSDictionary,
            let host = transmissionDict.value( forKey: "Host" ) as? String,
            let port = transmissionDict.value( forKey: "Port" ) as? Int
            else {
                displayAlert( window: self.window, message: "The file: \(defaultsPath) is corrupt.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        let mediaDisplayURL = self.userDefaults.url( forKey: "Media Display Directory")
        var mediaDirectoryURLs : [String:URL?] = self.getMediaDirectoryURL( mediaDirectoryURL: mediaDisplayURL )
        
        for (key,value) in mediaDirectoryURLs
        {
            if let url = value
            {
                if( url.lastPathComponent != mediaDirectoryName )
                {
                    mediaDirectoryURLs[ key ] = url.appendingPathComponent(mediaDirectoryName)
                }
            }
            else
            {
                displayAlert( window: self.window, message: "Could Not Create Media Directory", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
            }
        }
        
        guard let actualMediaURL = mediaDirectoryURLs["actual"] as? URL,
            let displayMediaURL = mediaDirectoryURLs["display"] as? URL
            else {
                displayAlert( window: self.window, message: "Could Not Create Media Directory", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        print("saving")
        print( displayMediaURL)
        print( actualMediaURL)
        self.userDefaults.set( displayMediaURL, forKey: "Media Display Directory")
        
        guard let downloadsManager = DownloadsManager( mediaDirectoryURL: actualMediaURL, downloadRegexes: downloadRegexes, videoExtensions: videoExtensions, subtitleExtensions: subtitleExtensions )
            else {
                displayAlert( window: self.window, message: "Error creating Download Manager.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        self.downloadsManager = downloadsManager

        if let eztv = EZTV()
        {
            self.eztv = eztv
            self.eztv?.search( callback: { (result: EZTV.Result) in
                print("search done")
            })
        }
        
        if let tvdb = TVDB(apiKey: apiKey, userKey: userKey, userName: userName)
        {
            self.tvdb = tvdb
            tvdb.authenticate( callback: { (authenticated: Bool ) -> () in
                if( authenticated )
                {
                    print("tvdb authenticated")
                }
                else
                {
                    self.displayAlert( window: self.window, message: "Could not connect to TV database. Searching will be disabled", buttonTitle: "OK", callback: { (success:Bool) in
                        print("disable searching")
                    })
                }
            })
        }
        else
        {
            displayAlert( window: self.window, message: "The file: \(defaultsPath) is corrupt.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                NSApplication.shared.terminate(self)
            })
            return
            
        }
        
        //self.searchResultsScrollView.isHidden = true
        if let seriesData = self.userDefaults.object(forKey: "series") as? Data
        {
            if let series = NSKeyedUnarchiver.unarchiveObject(with: seriesData) as? [TVDB.Series]
            {
                self.series = series
         //       self.seriesTableView.reloadData()
                
            }
            
            print("done loading keyed data: \(self.series.count)")
            
        }
        else
        {
            //
            //            print("could not load series")
        }
        
        // self.downloadsTableView.backgroundColor = NSColor.underPageBackgroundColor
        
        if let transmission = Transmission(host: host, port: port)
        {
            self.transmission = transmission
            transmission.authenticate( callback: { (authenticated: Bool ) -> () in
                if( authenticated )
                {
                    print( "transmission authenticated")
                    
                    downloadsManager.setTransmission(transmission: transmission)
                    
                    transmission.getSession( callback: { (session: Transmission.Session ) -> () in
                        downloadsManager.setDownloadsDirectory(path: session.download_dir)
                        //downloadsManager.updateDownloadDirectory()
                        downloadsManager.catalogDownloads(series: self.series )
                        
                        DispatchQueue.main.async(){
                            self.updateDownloadsTableView()
                        }
                    })
                }
                else
                {
                    print( "couldn't auth transmission")
                }
            })
        }
        else
        {
            print("no transmission")
        }
       /*
        downloadsManager.scheduleTransmissionTimer { (numRemoved:Int) in
            
            if( numRemoved > 0 )
            {
                downloadsManager.catalogDownloads(series: self.series )
            }
            
            DispatchQueue.main.async(){
                self.updateDownloadsTableView()
            }
        }
     */
        super.viewDidLoad()

        
    }
    
    func updateDownloadsTableView()
    {
        guard let downloadsManager = self.downloadsManager
            else {
                return
        }
        
        self.episodeFiles = downloadsManager.getDownloads()
        self.episodeFiles.sort( by:{ (lhs:DownloadsManager.EpisodeFile, rhs:DownloadsManager.EpisodeFile) -> Bool in
            if( lhs.percentDone == 1.0 && rhs.percentDone == 1.0 )
            {
                return lhs.prettyFileName < rhs.prettyFileName
            }
            else if( lhs.percentDone < 1.0 && rhs.percentDone < 1.0 )
            {
                return rhs.percentDone < lhs.percentDone // descending
            }
            
            return lhs.percentDone < rhs.percentDone // downloading first
        })
        self.downloadsTableView.reloadData()
    }
    
    func removeSeries( row: Int )
    {
        self.series.remove( at: row )
        let data = NSKeyedArchiver.archivedData( withRootObject: self.series )
        self.userDefaults.set( data, forKey: "series" )
        self.seriesTableView.reloadData()
        self.episodesTableView.reloadData()
        if( self.series.count > 0 )
        {
            let newRow = max( row - 1, 0 )
            self.seriesTableView.selectRowIndexes( IndexSet( integer: newRow ), byExtendingSelection: false )
        }
    }
    
    @IBAction func delete(_ sender: AnyObject)
    {
        if( seriesTableView.selectedRow >= 0 )
        {
            self.removeSeries( row: seriesTableView.selectedRow )
        }
    }
    
    func setSelectedSeries( withSeriesId: Int )
    {
        for i in 0..<self.series.count
        {
            let series = self.series[i]
            if( series.id == withSeriesId )
            {
                self.seriesTableView.selectRowIndexes(IndexSet(integer: i), byExtendingSelection: false)
                return
            }
        }
    }
    
    func searchButtonEnter(_ sender: NSSearchField) {
        
        guard let tvdb = self.tvdb
            else {
                return
        }
        
        self.searchResults = []
        self.seriesTableView.deselectAll(self.seriesTableView)
        self.displaySearchResults = true
        self.episodesTableView.backgroundColor = NSColor.textBackgroundColor
        self.episodesTableView.reloadData()
        tvdb.search(series: sender.stringValue,  callback: { ( result: TVDB.Result) -> () in
            
            DispatchQueue.main.async(){
                self.searchResults.append( result )
                //                self.searchResults.sort( by:{ (lhs:TVDB.Result, rhs:TVDB.Result) -> Bool in
                //                    if( lhs.status == rhs.status )
                //                    {
                //                        return rhs.first_aired < lhs.first_aired // descending
                //                    }
                //                    if( lhs.status == "Continuing")
                //                    {
                //                        return true
                //                    }
                //                    return false
                //                })
                self.episodesTableView.reloadData()
            }
        })
    }
    
    @IBAction func removeSeriesClick( _ sender: NSButton )
    {
        self.removeSeries( row: sender.tag )
    }
    
    @IBAction func addSeriesClick(_ sender: NSButton) {
        
        guard let tvdb = self.tvdb,
            let downloadsManager = self.downloadsManager
            else {
                return
        }
        
        let result = self.searchResults[ sender.tag ]
        
        tvdb.series(result: result, callback: { ( series: TVDB.Series ) -> () in
            DispatchQueue.main.async() {
                
                if( downloadsManager.addSeries(series: series ) )
                {
                    self.series.append( series )
                    let THE = "The "
                    let THE_LEN = THE.count
                    self.series.sort( by:{ (lhs:TVDB.Series, rhs:TVDB.Series) -> Bool in
                        var myLhs = lhs.name
                        var myRhs = rhs.name
                        if( myLhs.hasPrefix(THE) )
                        {
                            let end = myLhs.index(myLhs.startIndex, offsetBy: THE_LEN)
                            myLhs = myLhs.replacingCharacters(in: (myLhs.startIndex ..< end), with: "")
                        }
                        
                        if( myRhs.hasPrefix(THE) )
                        {
                            let end = myRhs.index(myRhs.startIndex, offsetBy: THE_LEN)
                            myRhs = myRhs.replacingCharacters(in: (myRhs.startIndex ..< end), with: "")
                        }
                        
                        return myLhs < myRhs
                    })
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.series)
                    self.userDefaults.set( data, forKey: "series")
                    
                    self.searchResults = []
                    
                    
                    if let windowController = self.windowController
                    {
                        windowController.searchField.stringValue = ""
                    }
                    
                    self.seriesTableView.reloadData()
                    self.setSelectedSeries(withSeriesId: result.id )
                    downloadsManager.catalogDownloads(series: self.series )
                    self.downloadsTableView.reloadData()
                }
            }
        })
    }
}
extension ViewController: NSSearchFieldDelegate {
    
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if( tableView == self.seriesTableView ) {
            if( self.series.count == 0 )
            {
                
                let noDataLabel = NSTextView(frame: tableView.bounds )
                noDataLabel.string = "No Series Added"
                /*
                 UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
                 noDataLabel.text             = @"No data available";
                 noDataLabel.textColor        = [UIColor blackColor];
                 noDataLabel.textAlignment    = NSTextAlignmentCenter;
                 */
                //yourTableView.backgroundView = noDataLabel;
                //yourTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                //tableView.bac
                //   tableView.backgroundView = noDataLabel;
                // tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                // }
            }
            return self.series.count
        }
        else if( tableView == self.episodesTableView) {
            if( self.displaySearchResults == true )
            {
                return self.searchResults.count
            }
            
            if( seriesTableView.selectedRow >= 0 )
            {
                let series = self.series[ self.seriesTableView.selectedRow ]
                return self.seasonGroupingHelper.numRows( series: series )
            }
            return 0
        }
        else if( tableView == self.downloadsTableView ) {
            
            return self.episodeFiles.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if( tableView == self.episodesTableView) {
            if( self.displaySearchResults == true )
            {
                return 300
            }
            
            if( seriesTableView.selectedRow >= 0 )
            {
                if( row == 0 )
                {
                    return 300
                }
                let series = self.series[ self.seriesTableView.selectedRow ]
                if( self.seasonGroupingHelper.getEpisode(series: series, row: row) == nil )
                {
                    return 25
                }
                return 95
            }
        }
        else if( tableView == self.downloadsTableView ) {
            return 55
        }
        return 55
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if( self.displaySearchResults == true )
        {
            return false
        }
        
        if( tableView == episodesTableView )
        {
            if( seriesTableView.selectedRow >= 0 )
            {
                //let series = self.series[ seriesTableView.selectedRow ]
                //return self.seasonGroupingHelper.getEpisode( series: series, row: row ) == nil
                return false
            }
        }
        return false
    }
    
    func makeSearchResultCell( result: TVDB.Result, tag: Int ) -> NSView?
    {
        if let cell = episodesTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SearchResultsTableCellID"), owner: nil) as? SearchResultsTableCellView
        {
            cell.wantsLayer = true;
            if let cell_layer = cell.layer
            {
                if let img = NSImage(contentsOf: result.bannerURL)
                {
                    cell.imageView?.image = NSImage(contentsOf: result.bannerURL)
                    
                    if let analyzer = ColorAnalyzer(image: img )
                    {
                        if( tag == 0 )
                        {
                            episodesTableView.backgroundColor = analyzer.backgroundColor
                        }
                        cell_layer.backgroundColor = analyzer.backgroundColor.cgColor
                        
                        cell.nameTextfield.textColor = analyzer.primaryColor
                        cell.yearTextfield.textColor = analyzer.primaryColor
                        cell.overviewTextfield.textColor = analyzer.primaryColor
                        cell.networkTextfield.textColor = analyzer.primaryColor
                    }
                }
                else
                {
                    cell.imageView?.image = NSImage()
                    cell_layer.backgroundColor = NSColor.textBackgroundColor.cgColor
                    
                    cell.nameTextfield.textColor = NSColor.textColor
                    cell.yearTextfield.textColor = NSColor.textColor
                    cell.overviewTextfield.textColor = NSColor.textColor
                    cell.networkTextfield.textColor = NSColor.textColor
                }
            }
            
            cell.nameTextfield.stringValue = result.name
            cell.yearTextfield.stringValue = result.first_aired
            cell.overviewTextfield.stringValue = result.overview
            cell.seriesButton.tag = tag
            cell.networkTextfield.stringValue = result.network
            
            if( result.status == "Continuing")
            {
                cell.statusImageView.image = NSImage(named: NSImage.Name.statusAvailable)
            }
            else
            {
                cell.statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            }
            
            
            
            return cell
        }
        return nil
    }
    
    func makeSeriesCell( series: TVDB.Series, tag: Int ) -> NSView?
    {
        if let cell = self.episodesTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SeriesTableCellID"), owner: nil) as? SeriesTableCellView
        {
            if let img = NSImage(contentsOf: series.bannerURL)
            {
                cell.imageView?.image = img
                if let analyzer = ColorAnalyzer(image: img )
                {
                    self.seriesColorAnalyzer = analyzer
                    self.episodesTableView.backgroundColor = analyzer.backgroundColor
                }
            }
            else
            {
                self.seriesColorAnalyzer = nil //clear it out
                cell.imageView?.image = NSImage()
                self.episodesTableView.backgroundColor = NSColor.textBackgroundColor
            }
            cell.nameTextfield.stringValue = series.name
            cell.yearTextfield.stringValue = series.first_aired
            cell.overviewTextfield.stringValue = series.overview
            cell.seriesButton.tag = tag
            
            if( series.status == "Continuing")
            {
                cell.statusImageView.image = NSImage(named: NSImage.Name.statusAvailable)
            }
            else
            {
                cell.statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            }
            
            cell.networkTextfield.stringValue = series.network
            
            return cell
        }
        return nil
    }
    
    func makeEpisodeCell( series: TVDB.Series, episode: TVDB.Episode, tag: Int ) -> NSView?
    {
        if let cell = episodesTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EpisodeTableCellID"), owner: nil) as? EpisodeTableCellView
        {
            cell.titleTextfield?.stringValue = episode.name
            cell.episodeTextField?.stringValue = String( format: "Episode %02d", episode.episode_number)
            cell.overviewTextField?.stringValue = String( episode.overview)
            if let downloadsManager = self.downloadsManager
            {
                let (status, percentDone) = downloadsManager.episodeStatus(series: series, episode: episode)
                
                cell.percentDoneTextField.stringValue = String(format: "%.2f%%", percentDone * 100.0)
                cell.statusImageView.image = NSImage(named: NSImage.Name(rawValue: downloadsManager.getEpisodeIcon(status: status )) )
                
                let showDownloadingPercent = status == DownloadsManager.EpisodeStatus.downloading
                cell.percentDoneTextField.isHidden = !showDownloadingPercent
                cell.percentDoneTextField.isHidden = true
                cell.statusImageView.isHidden = showDownloadingPercent
                cell.statusImageView.isHidden = false
            }
            
            return cell
        }
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if let col = tableColumn
        {
            if( tableView == episodesTableView )
            {
                if( self.displaySearchResults == true )
                {
                    if( row < self.searchResults.count )
                    {
                        let searchResult = self.searchResults[ row ]
                        return self.makeSearchResultCell( result: searchResult, tag: row )
                    }
                }
                else if( row == 0 )
                {
                    let series = self.series[ seriesTableView.selectedRow ]
                    return self.makeSeriesCell(series: series, tag: seriesTableView.selectedRow )
                }
                else if( seriesTableView.selectedRow >= 0 )
                {
                    if( col.identifier.rawValue == "EpisodeCellID")
                    {
                        let series = self.series[ seriesTableView.selectedRow ]
                        if let episode = self.seasonGroupingHelper.getEpisode(series: series, row: row )
                        {
                            return self.makeEpisodeCell( series: series, episode: episode, tag: row )
                        }
                        else
                        {
                            if let cell = episodesTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SeasonGroupCellID"), owner: nil) as? NSTableCellView
                            {
                                if let seasonNumber = self.seasonGroupingHelper.groupingSeason[ row ]
                                {
                                    
                                    cell.textField?.stringValue = String(format: "Season %02d", seasonNumber )
                                    if let analyzer = self.seriesColorAnalyzer
                                    {
                                        cell.textField?.textColor = analyzer.primaryColor
                                    }
                                    
                                    return cell
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                if let cell = tableView.makeView(withIdentifier: col.identifier, owner: nil) as? NSTableCellView
                {
                    if( tableView == self.seriesTableView )
                    {
                        cell.imageView?.image = NSImage(contentsOf: self.series[ row ].bannerURL ) ?? nil
                    }
                    else if( tableView == self.downloadsTableView )
                    {
                        let episodeFile = self.episodeFiles[ row ]
                        cell.textField?.stringValue = episodeFile.prettyFileName + " ( \(episodeFile.percentDone * 100.0)% )"
                    }
                    return cell
                }
            }
        }
        else
        {
            if let seasonNumber = self.seasonGroupingHelper.groupingSeason[ row ]
            {
                if( seasonNumber == 0 )
                {
                    let series = self.series[ seriesTableView.selectedRow ]
                    return self.makeSeriesCell(series: series, tag: seriesTableView.selectedRow )
                }
                else
                {
                    if let cell = episodesTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SeasonGroupCellID"), owner: nil) as? NSTableCellView
                    {
                        cell.textField?.stringValue = String(format: "Season %02d", seasonNumber )
                        
                        return cell
                    }
                }
            }
            else
            {
                print("no season \(row)")
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            if( tableView == self.seriesTableView )
            {
                if( tableView.selectedRow >= 0 )
                {
                    self.seasonGroupingHelper.reset()
                    
                    self.displaySearchResults = false
                    episodesTableView.scrollRowToVisible(0)
                    episodesTableView.reloadData()
                }
            }
        }
    }
    
    
}
