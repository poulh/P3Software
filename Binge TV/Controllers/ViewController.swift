//
//  ViewController.swift
//  TvTime
//
//  Created by Poul Hornsleth on 11/2/17.
//  Copyright © 2017 Poul Hornsleth. All rights reserved.
//

import Cocoa
import UIImageColors
//import NetworkExtension

class ViewController: NSViewController {
    
    @IBOutlet weak var seriesTableView: NSTableView!
    @IBOutlet weak var episodesTableView: NSTableView!
    @IBOutlet weak var downloadsTableView: NSTableView!
    
    @IBOutlet weak var seriesLabel: NSTextField!
    @IBOutlet weak var downloadsLabel: NSTextField!
    
    //models
    var episodes: [String] = []
    var searchResults: [TVDB.Result] = []
    var episodeFiles : [ DownloadsManager.EpisodeFile ] = []
    var displaySearchResults = false
    var imageColors :ImageColors?
    
    // view helpers
    let seasonGroupingHelper = SeasonGroupingHelper()
    let mediaDirectoryHelper = MediaDirectoryHelper()
        
    //data fetchers
    var tvdb: TVDB?
    var eztv: EZTV?
    var downloadsManager: DownloadsManager?
    
    var window : NSWindow?
    {
        get {
            return self.view.window
        }
    }
    var windowController : WindowController?
    {
        get {
            return self.window?.windowController as? WindowController
        }
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
        super.viewWillAppear()
        
        guard let empty = self.downloadsManager?.series.isEmpty
            else {
                return
        }
        
        if( !empty )
        {
            self.seriesTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print("------")
        for ( key, value ) in change!
        {
            print ("\(key) : \(value)" )
        }
        print("------")
      
        initDownloadManager()
    }
    
    func initDownloadManager()
    {
        guard let downloadsManager = DownloadsManager( defaults: UserDefaults.standard )
            else {
                return
        }
        
        downloadsManager.initDownloader { (success: Bool ) in
            if( success )
            {
                downloadsManager.startDownloadStatusTimer(callback: { (downloadsRemoved: Int ) in
                    DispatchQueue.main.async() {
                        self.updateDownloadsTableView()
                    }
                })
                
                downloadsManager.startSearchForMissingEpisodesTimer()
            }
        }
        
        self.downloadsManager = downloadsManager
        self.seasonGroupingHelper.reset()
        self.episodesTableView.reloadData()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let defaultsPath = Bundle.main.path(forResource: "Defaults", ofType: "plist"),
            let defaultsProperties = NSDictionary(contentsOfFile: defaultsPath )
            else {
                displayAlert( window: self.window, message: "Could not load defaults file.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        guard let downloadsManagerDict = defaultsProperties.value( forKey: "Downloads Manager") as? NSDictionary,
            let videoExtensions = downloadsManagerDict.value( forKey: VIDEO_EXTENSIONS ) as? Array<String>,
            let subtitleExtensions = downloadsManagerDict.value( forKey: SUBTITLE_EXTENSIONS ) as? Array<String>,
            let downloadRegexes = downloadsManagerDict.value( forKey: FILENAME_REGEX ) as? Array<String>,
            let mediaDirectoryName = downloadsManagerDict.value( forKey: "Media Directory Name" ) as? String,
            let tvdbDict = defaultsProperties.value(forKey: "TVDB") as? NSDictionary,
            let apiKey = tvdbDict.value( forKey: "API Key" ) as? String,
            let userKey = tvdbDict.value( forKey: "User Key" ) as? String,
            let userName = tvdbDict.value( forKey: "User Name" ) as? String,
            let transmissionDict = defaultsProperties.value( forKey: "Downloader" ) as? NSDictionary,
            let transmissionHost = transmissionDict.value( forKey: TRANSMISSION_HOST ) as? String,
            let transmissionPort = transmissionDict.value( forKey: TRANSMISSION_PORT ) as? Int,
            let transmissionPath = transmissionDict.value( forKey: TRANSMISSION_PATH ) as? String
            else {
                displayAlert( window: self.window, message: "The file: \(defaultsPath) is corrupt.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        UserDefaults.standard.register( defaults: [VIDEO_EXTENSIONS : videoExtensions,
                                                   SUBTITLE_EXTENSIONS : subtitleExtensions,
                                                   FILENAME_REGEX : downloadRegexes,
                                                   MEDIA_DIRECTORY_NAME : mediaDirectoryName,
                                                   TRANSMISSION_HOST : transmissionHost,
                                                   TRANSMISSION_PORT : transmissionPort,
                                                   TRANSMISSION_PATH : transmissionPath ] )

        let defaults = UserDefaults.standard
        
        defaults.addObserver(self,
                             forKeyPath: MEDIA_ACTUAL_DIRECTORY,
                             options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue ),
                             context: nil)
        
       

        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { (notificaton:Notification) in
        
            self.initDownloadManager()
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil) { (notificaton:Notification) in
            
            if let downloadsManager = self.downloadsManager
            {
                downloadsManager.stopAllTimers()
            }
            self.downloadsManager = nil
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
        
        guard let mediaDirectoryInfo = self.mediaDirectoryHelper.getMediaDirectoryURL( displayDirectoryURL: defaults.url(forKey: MEDIA_DISPLAY_DIRECTORY ), mediaDirectoryName: defaults.string(forKey: MEDIA_DIRECTORY_NAME )! )
            else {
                displayAlert( window: self.window, message: "Could Not Create Media Directory", buttonTitle: "Quit", callback: { (success:Bool) in
                    NSApplication.shared.terminate(self)
                })
                return
        }
        
        defaults.set(mediaDirectoryInfo.displayURL, forKey: MEDIA_DISPLAY_DIRECTORY)
        defaults.set(mediaDirectoryInfo.actualURL, forKey: MEDIA_ACTUAL_DIRECTORY )
        
        initDownloadManager()

        if( self.downloadsManager == nil )
        {
            self.displayAlert( window: self.window, message: "Error creating Download Manager.\n\nPlease contact the developer.", buttonTitle: "Quit", callback: { (success:Bool) in
                NSApplication.shared.terminate(self)
            })
        }
    }
    
    func updateDownloadsTableView()
    {
        guard let downloadsManager = self.downloadsManager
            else {
                return
        }
        
        self.episodeFiles = downloadsManager.episodeFileDownloads
        if let column = self.downloadsTableView.tableColumns.first
        {
            let count = self.episodeFiles.count
            if( count == 1 )
            {
                column.headerCell.stringValue = "\(count) Download"
            }
            else
            {
                column.headerCell.stringValue = "\(count) Downloads"
            }
        }

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
        guard let downloadsManager = self.downloadsManager
            else {
                return
        }
        
        if( row >= downloadsManager.series.count )
        {
            return
        }
        
        if( row < 0 )
        {
            return
        }
        
        downloadsManager.removeSeries( at: row )

        self.seriesTableView.reloadData()
        self.episodesTableView.reloadData()
        if( downloadsManager.series.count > 0 )
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
        guard let downloadsManager = self.downloadsManager
            else {
                return
        }
        
        for i in 0..<downloadsManager.series.count
        {
            let series = downloadsManager.series[i]
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
                    self.searchResults = []
                    
                    self.windowController?.searchField.stringValue = ""
               
                    self.seriesTableView.reloadData()
                    self.setSelectedSeries(withSeriesId: result.id )
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
        guard let downloadsManager = self.downloadsManager
            else {
                return 0
        }
        
        if( tableView == self.seriesTableView ) {
            if( downloadsManager.series.count == 0 )
            {
                
                let noDataLabel = NSTextView(frame: tableView.bounds )
                noDataLabel.string = "No Series Added"
            }
            return downloadsManager.series.count
        }
        else if( tableView == self.episodesTableView) {
            if( self.displaySearchResults == true )
            {
                return self.searchResults.count
            }
            
            if( seriesTableView.selectedRow >= 0 )
            {
                let series = downloadsManager.series[ self.seriesTableView.selectedRow ]
                return self.seasonGroupingHelper.numRows( series: series )
            }
            return 0
        }
        else if( tableView == self.downloadsTableView ) {
            let count = self.episodeFiles.count
            self.downloadsLabel.isHidden = ( count > 0 )
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let downloadsManager = self.downloadsManager
            else {
                return 0
        }
        
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
                let series = downloadsManager.series[ self.seriesTableView.selectedRow ]
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
                   
                    self.imageColors = img.getColors()
                    if let imageColors = self.imageColors
                    {
                        if( tag == 0 )
                        {
                            episodesTableView.backgroundColor = imageColors.background
                        }
                        cell_layer.backgroundColor = imageColors.background.cgColor
                        
                        cell.nameTextfield.textColor = imageColors.primary
                        cell.yearTextfield.textColor = imageColors.primary
                        cell.overviewTextfield.textColor = imageColors.primary
                        cell.networkTextfield.textColor = imageColors.primary
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
                self.imageColors = img.getColors()
                if let imageColors = self.imageColors
                {
                    self.episodesTableView.backgroundColor = imageColors.background
                }
            }
            else
            {
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
        guard let downloadsManager = self.downloadsManager
            else {
                return nil
        }
        
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
                    let series = downloadsManager.series[ seriesTableView.selectedRow ]
                    return self.makeSeriesCell(series: series, tag: seriesTableView.selectedRow )
                }
                else if( seriesTableView.selectedRow >= 0 )
                {
                    if( col.identifier.rawValue == "EpisodeCellID")
                    {
                        let series = downloadsManager.series[ seriesTableView.selectedRow ]
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
                                    
                                    if let imageColors = self.imageColors
                                    {
                                        cell.textField?.textColor = imageColors.primary
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
                if( tableView == self.seriesTableView )
                {
                    if let cell = tableView.makeView(withIdentifier: col.identifier, owner: nil) as? NSTableCellView
                    {
                        cell.imageView?.image = NSImage(contentsOf: downloadsManager.series[ row ].bannerURL ) ?? nil
                        return cell
                    }
                }
                else if( tableView == self.downloadsTableView )
                {
                    if let cell = tableView.makeView(withIdentifier: col.identifier, owner: nil) as? DownloadStatusCellView
                    {
                        let episodeFile = self.episodeFiles[ row ]
                        cell.textField?.stringValue = episodeFile.prettyFileName
                        cell.progressIndicator.doubleValue = episodeFile.percentDone * 100.0
                        return cell
                    }
                }
                
            }
            
        }
        else
        {
            if let seasonNumber = self.seasonGroupingHelper.groupingSeason[ row ]
            {
                if( seasonNumber == 0 )
                {
                    let series = downloadsManager.series[ seriesTableView.selectedRow ]
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
