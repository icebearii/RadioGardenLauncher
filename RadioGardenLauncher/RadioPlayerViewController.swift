import Cocoa
import AVFoundation

// Key for saving font size preference
private let kFontSizeKey = "AppFontSizePreference"

class RadioPlayerViewController: NSViewController {
    
    // --- Use a single, persistent player instance ---
    private var player: AVPlayer? = AVPlayer() // Initialize player once
    // --- End single player instance ---
    
    private var currentStation: RadioStation? // Keep track of the logical station
    private let radioService = RadioGardenService()
    private var stations: [RadioStation] = []
    private var favorites: [RadioStation] = []
    private var currentFontSize: CGFloat = NSFont.systemFontSize // Default size
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    
    private lazy var segmentedControl: NSSegmentedControl = {
        let control = NSSegmentedControl(labels: ["All Stations", "Favorites"], trackingMode: .selectOne, target: self, action: #selector(segmentChanged))
        control.selectedSegment = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var searchField: NSTextField = {
        let textField = NSTextField()
        textField.placeholderString = "Search stations or enter stream URL..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var searchButton: NSButton = {
        let button = NSButton(title: "Search", target: self, action: #selector(searchStations))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stationsTableView: NSTableView = {
        let tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("StationColumn"))
        column.title = "Stations"
        column.width = 200
        tableView.addTableColumn(column)
        tableView.headerView = nil
        
        return tableView
    }()
    
    private lazy var playButton: NSButton = {
        let button = NSButton(title: "Play", target: self, action: #selector(togglePlayback))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var favoriteButton: NSButton = {
        let button = NSButton(title: "Add to Favorites", target: self, action: #selector(toggleFavorite))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var volumeSlider: NSSlider = {
        let slider = NSSlider()
        slider.minValue = 0
        slider.maxValue = 100
        slider.intValue = 50
        slider.target = self
        slider.action = #selector(volumeChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var testPlayButton: NSButton = {
        let button = NSButton(title: "Test Sound", target: self, action: #selector(testPlayback))
        button.toolTip = "Plays a short sound effect to test audio output."
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // --- Font Size Controls ---
    private lazy var fontSizeLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Font Size: \(Int(currentFontSize))pt")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fontSizeStepper: NSStepper = {
        let stepper = NSStepper()
        stepper.minValue = 10
        stepper.maxValue = 20
        stepper.increment = 1
        stepper.valueWraps = false
        stepper.target = self
        stepper.action = #selector(fontSizeChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    // --- End Font Size Controls ---
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RadioPlayerViewController viewDidLoad")
        loadFontSizePreference() // Load saved font size
        setupUI()
        loadStations()
    }
    
    private func loadFontSizePreference() {
        let savedSize = UserDefaults.standard.double(forKey: kFontSizeKey)
        if savedSize > 0 {
            currentFontSize = CGFloat(savedSize)
        } else {
            currentFontSize = NSFont.systemFontSize // Default if nothing saved
        }
        fontSizeStepper.doubleValue = currentFontSize // Sync stepper
        fontSizeLabel.stringValue = "Font Size: \(Int(currentFontSize))pt" // Update label
        print("Loaded font size: \(currentFontSize)")
    }
    
    private func saveFontSizePreference() {
        UserDefaults.standard.set(currentFontSize, forKey: kFontSizeKey)
        print("Saved font size: \(currentFontSize)")
    }
    
    private func setupUI() {
        print("Setting up UI...")
        view.addSubview(segmentedControl)
        view.addSubview(searchField)
        view.addSubview(searchButton)
        view.addSubview(stationsTableView)
        
        print("Adding playButton...")
        view.addSubview(playButton)
        print("Adding testPlayButton...")
        view.addSubview(testPlayButton)
        print("Adding favoriteButton...")
        view.addSubview(favoriteButton)
        print("Adding volumeSlider...")
        view.addSubview(volumeSlider)
        
        // Add Font Controls
        print("Adding fontSizeLabel...")
        view.addSubview(fontSizeLabel)
        print("Adding fontSizeStepper...")
        view.addSubview(fontSizeStepper)
        
        print("All views added.")
        
        NSLayoutConstraint.activate([
            // Top elements
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchField.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            
            searchButton.topAnchor.constraint(equalTo: searchField.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 60),
            
            // Table View - Allow flexible height, but constrain bottom relative to controls
            stationsTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            stationsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stationsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Remove fixed height, constrain bottom instead
            // stationsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            // Bottom elements - Anchor from bottom up
            fontSizeStepper.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            fontSizeStepper.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fontSizeLabel.centerYAnchor.constraint(equalTo: fontSizeStepper.centerYAnchor),
            fontSizeLabel.trailingAnchor.constraint(equalTo: fontSizeStepper.leadingAnchor, constant: -10),
            
            volumeSlider.bottomAnchor.constraint(equalTo: fontSizeStepper.topAnchor, constant: -15), // Above font controls
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            favoriteButton.bottomAnchor.constraint(equalTo: volumeSlider.topAnchor, constant: -20),
            favoriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Play and Test buttons above Favorite button
            playButton.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -10),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            
            testPlayButton.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -10),
            testPlayButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            testPlayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testPlayButton.widthAnchor.constraint(equalTo: playButton.widthAnchor),
            
            // Connect table view bottom to the top of the play/test buttons
            stationsTableView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -20)
        ])
        print("Constraints activated.")
    }
    
    private func loadStations() {
        Task {
            do {
                // Fetch both popular stations (now returns defaults) and favorites
                async let defaultOrPopularStations = radioService.getPopularStations()
                let favoriteStations = radioService.getFavorites()
                
                // Await results
                self.stations = try await defaultOrPopularStations
                self.favorites = favoriteStations
                
                // Ensure UI update happens on the main thread
                DispatchQueue.main.async {
                    print("Stations loaded. All: \(self.stations.count), Favs: \(self.favorites.count)")
                    self.stationsTableView.reloadData()
                    self.updateFavoriteButtonState() // Update button based on initial selection or lack thereof
                    // Select the first favorite by default if available
                    if self.segmentedControl.selectedSegment == 1 && !self.favorites.isEmpty {
                        self.stationsTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                    }
                }
            } catch {
                // Ensure UI update happens on the main thread
                DispatchQueue.main.async {
                    print("Error loading stations: \(error)")
                    // Show an error message to the user
                    let alert = NSAlert()
                    alert.messageText = "Error Loading Stations"
                    alert.informativeText = "Could not load station list. Please check your internet connection or try again later.\nError: \(error.localizedDescription)"
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }
    
    @objc private func segmentChanged() {
        stationsTableView.reloadData()
    }
    
    @objc private func searchStations() {
        let query = searchField.stringValue
        // No guard here - an empty query should trigger showing the full list
        print("Search field text: '\(query)'")
        
        // Check if the query is a URL
        if !query.isEmpty, let url = URL(string: query) { // Only check for URL if query is not empty
            print("Query detected as potential URL: \(url)")
            Task {
                if await radioService.validateStreamURL(url) {
                    print("URL validation successful.")
                    let station = radioService.createCustomStation(url: url, name: url.lastPathComponent)
                    self.stations = [station] // Show only the custom station
                    DispatchQueue.main.async {
                        self.segmentedControl.selectedSegment = 0 // Switch to All Stations view
                        self.stationsTableView.reloadData()
                    }
                } else {
                    print("URL validation failed.")
                    // Show error alert
                    DispatchQueue.main.async {
                         let alert = NSAlert()
                         alert.messageText = "Invalid Stream URL"
                         alert.informativeText = "Could not validate the entered URL. Please check the URL and your internet connection."
                         alert.alertStyle = .warning
                         alert.addButton(withTitle: "OK")
                         alert.runModal()
                    }
                }
            }
        } else {
            // Regular search (or empty query to show all)
            print("Performing directory search for '\(query)'")
            Task {
                do {
                    // This now searches the local directory or returns all if query is empty
                    let results = try await radioService.searchStations(query: query)
                    self.stations = results
                    DispatchQueue.main.async {
                        print("Search complete. Found \(self.stations.count) stations.")
                        self.segmentedControl.selectedSegment = 0 // Switch to All Stations view
                        self.stationsTableView.reloadData()
                    }
                } catch {
                    // This catch might be less likely now but keep for safety
                    DispatchQueue.main.async {
                        print("Error during local station search: \(error)")
                        let alert = NSAlert()
                        alert.messageText = "Search Error"
                        alert.informativeText = "An unexpected error occurred during the search."
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
        }
    }
    
    @objc private func togglePlayback() {
        let selectedRow = stationsTableView.selectedRow
        print("Play button clicked. Selected row: \(selectedRow)")
        
        if player?.timeControlStatus == .playing {
            print("Player is playing, pausing.")
            player?.pause()
            // KVO observer will update button title
        } else {
            if selectedRow >= 0 && selectedRow < currentStations.count {
                let station = currentStations[selectedRow]
                print("Selected station found: \(station.name). Attempting playback.")
                playStation(station)
            } else {
                 print("No station selected or selection is invalid.")
                 // Optionally show an alert
                 let alert = NSAlert()
                 alert.messageText = "No Station Selected"
                 alert.informativeText = "Please select a station from the list before pressing Play."
                 alert.alertStyle = .informational
                 alert.addButton(withTitle: "OK")
                 alert.runModal()
            }
        }
    }
    
    @objc private func toggleFavorite() {
        let selectedRow = stationsTableView.selectedRow
        if selectedRow >= 0 && selectedRow < currentStations.count {
            let station = currentStations[selectedRow]
            if favorites.contains(where: { $0.url == station.url }) {
                radioService.removeFavorite(station)
                favorites.removeAll { $0.url == station.url }
                favoriteButton.title = "Add to Favorites"
            } else {
                radioService.addFavorite(station)
                favorites.append(station)
                favoriteButton.title = "Remove from Favorites"
            }
            stationsTableView.reloadData()
        }
    }
    
    private func playStation(_ station: RadioStation) {
        print("Attempting to play station: \(station.name) - \(station.url)")
        currentStation = station
        
        // --- Stop previous item and remove observers ---
        player?.pause() // Pause the shared player
        // Explicitly remove observers before replacing item
        playerItemStatusObserver = nil
        playerTimeControlStatusObserver = nil
        // --- End stop previous item ---
        
        // Handle potential Radio Garden page URL vs actual stream URL
        let streamURL: URL
        if station.type == .radioGarden && !station.url.absoluteString.contains("listen") {
            // This is likely an API URL, need to fetch the actual stream URL
            // Placeholder: Fetch actual stream URL here. For now, log and potentially fail.
            print("Error: Radio Garden API URL detected, need to fetch stream URL for \(station.url)")
            // Show error to user?
            return // Or attempt to play anyway if the URL *might* work
        } else if station.type == .radioGarden && station.url.absoluteString.contains("listen") {
            // This is a page URL, ideally we extract the stream URL from the page
            // Placeholder: Extract stream URL here. For now, log and potentially fail.
             print("Error: Radio Garden page URL detected, need to extract stream URL for \(station.url)")
            // Show error to user?
             return
        } else {
            streamURL = station.url // Assume direct stream or correctly formatted URL
        }

        print("Creating player item assets for URL: \(streamURL)")
        // --- Set Custom User Agent ---
        let assetOptions = [
            "AVURLAssetHTTPHeaderFieldsKey": [
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.3 Safari/605.1.15"
            ]
        ]
        let asset = AVURLAsset(url: streamURL, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset) // Create item from asset
        // --- End Custom User Agent ---
        
        // --- Observe New Player Item Status ---
        playerItemStatusObserver = playerItem.observe(\.status, options: [.old, .new]) { [weak self] (item, change) in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    print("PlayerItem status: Ready to play")
                case .failed:
                    print("PlayerItem status: Failed")
                    if let error = item.error as NSError? {
                        print("PlayerItem Error: \(error.localizedDescription) (Domain: \(error.domain), Code: \(error.code))")
                        // Show alert to user about playback failure
                        let alert = NSAlert()
                        alert.messageText = "Playback Error"
                        alert.informativeText = "Could not play the selected station.\nError: \(error.localizedDescription)"
                        alert.alertStyle = .critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                case .unknown:
                    print("PlayerItem status: Unknown")
                @unknown default:
                    print("PlayerItem status: Unexpected default")
                }
            }
        }
        // --- End Observe New Player Item Status ---
        
        // --- Replace item and setup observers for the SHARED player ---
        player?.replaceCurrentItem(with: playerItem) // Use replaceCurrentItem
        
        // Observe the SHARED player's timeControlStatus
        playerTimeControlStatusObserver = player?.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] (player, change) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch player.timeControlStatus {
                case .paused:
                    self.playButton.title = "Play"
                    print("Player TimeControlStatus: Paused")
                case .playing:
                    self.playButton.title = "Pause"
                    print("Player TimeControlStatus: Playing")
                case .waitingToPlayAtSpecifiedRate:
                     self.playButton.title = "Buffering..."
                     print("Player TimeControlStatus: Waiting/Buffering (\(player.reasonForWaitingToPlay?.rawValue ?? "unknown reason")")
                @unknown default:
                     self.playButton.title = "Play"
                }
            }
        }
        // --- End replace item and setup observers ---
        
        player?.volume = Float(volumeSlider.intValue) / 100.0 // Apply volume
        player?.play()
        
        updateFavoriteButtonState()
    }
    
    deinit {
        // Observers are automatically removed when playerItemStatusObserver/playerTimeControlStatusObserver are deallocated
        player?.pause() // Stop player on deinit
        print("RadioPlayerViewController deinit")
    }
    
    @objc private func testPlayback() {
        print("--- Test Sound Button Clicked ---")
        // Try a standard MP3 sound effect
        guard let testURL = URL(string: "https://interactive-examples.mdn.mozilla.net/media/cc0-audio/t-rex-roar.mp3") else { 
            print("ERROR: Invalid test sound URL")
            return 
        }
        print("Attempting to play test sound from: \(testURL)")
        
        // --- Stop previous item and remove observers ---
        player?.pause()
        playerItemStatusObserver = nil
        playerTimeControlStatusObserver = nil
        // --- End stop previous item ---

        let playerItem = AVPlayerItem(url: testURL)
        
        // Observe status for the test item
        playerItemStatusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] (item, change) in
             DispatchQueue.main.async {
                 print("Test sound PlayerItem status: \(item.status.rawValue)")
                 if item.status == .failed,
                    let error = item.error as NSError? {
                     print("Test sound PlayerItem Error: \(error.localizedDescription) (Code: \(error.code))")
                     let alert = NSAlert()
                     alert.messageText = "Test Sound Error"
                     alert.informativeText = "Could not play the test sound.\nError: \(error.localizedDescription)"
                     alert.alertStyle = .critical
                     alert.addButton(withTitle: "OK")
                     alert.runModal()
                 }
             }
         }
        
        // --- Replace item and setup observers for the SHARED player ---
        print("Replacing current item with test sound item...")
        player?.replaceCurrentItem(with: playerItem)
        print("Item replaced.")
        
        // Observe the SHARED player's timeControlStatus
        playerTimeControlStatusObserver = player?.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] (player, change) in
             DispatchQueue.main.async {
                guard let self = self else { return }
                // Update button based on player state (optional for test sound)
                 switch player.timeControlStatus {
                 case .paused: print("Test sound TimeControlStatus: Paused")
                 case .playing: print("Test sound TimeControlStatus: Playing")
                 case .waitingToPlayAtSpecifiedRate: print("Test sound TimeControlStatus: Waiting/Buffering")
                 @unknown default: break
                 }
             }
         }
         // --- End replace item and setup observers ---
        
        player?.volume = Float(volumeSlider.intValue) / 100.0 // Ensure volume is set
        player?.play()
        
        print("Test sound playback initiated.")
    }
    
    @objc private func volumeChanged() {
        player?.volume = Float(volumeSlider.intValue) / 100.0
    }
    
    @objc private func fontSizeChanged() {
        currentFontSize = CGFloat(fontSizeStepper.doubleValue)
        fontSizeLabel.stringValue = "Font Size: \(Int(currentFontSize))pt"
        print("Font size changed to: \(currentFontSize)")
        stationsTableView.reloadData() // Redraw table cells with new font size
        saveFontSizePreference() // Save the new preference
    }
    
    private var currentStations: [RadioStation] {
        segmentedControl.selectedSegment == 0 ? stations : favorites
    }
    
    private func updateFavoriteButtonState() {
        let selectedRow = stationsTableView.selectedRow
        if selectedRow >= 0 && selectedRow < currentStations.count {
            let station = currentStations[selectedRow]
            favoriteButton.isEnabled = true
            favoriteButton.title = favorites.contains(where: { $0.url == station.url }) ? "Remove Favorite" : "Add Favorite"
        } else {
            favoriteButton.isEnabled = false
            favoriteButton.title = "Add Favorite"
        }
    }
}

extension RadioPlayerViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentStations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let station = currentStations[row]
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("StationCell")
        var cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView
        
        if cell == nil {
            cell = NSTableCellView()
            let textField = NSTextField()
            textField.isEditable = false
            textField.isBordered = false
            textField.backgroundColor = .clear
            textField.translatesAutoresizingMaskIntoConstraints = false
            cell?.textField = textField // Use the built-in textField property
            cell?.addSubview(textField)
            cell?.identifier = cellIdentifier
            
            if let cellTextField = cell?.textField {
                 NSLayoutConstraint.activate([
                     cellTextField.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 5),
                     cellTextField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -5),
                     cellTextField.centerYAnchor.constraint(equalTo: cell!.centerYAnchor)
                 ])
            }
        }
        
        // Apply current font size
        cell?.textField?.font = NSFont.systemFont(ofSize: currentFontSize)
        cell?.textField?.stringValue = "\(station.name) - \(station.country)"
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
       updateFavoriteButtonState()
    }
} 
