import Foundation

class RadioGardenService {
    // private let baseURL = "https://radio.garden/api" // No longer needed for API calls
    private let favoritesKey = "FavoriteStations"
    
    // Removed defaultStations here, now uses the directory
    
    init() {
        // No longer auto-adding favorites on init
    }
    
    func searchStations(query: String) async throws -> [RadioStation] {
        print("Performing local search for: '\(query)'")
        if query.isEmpty {
            // If search is cleared, return the full directory
            return StationsDirectory.globalStationDirectory
        } else {
            // Perform case-insensitive search on name and country
            let lowercasedQuery = query.lowercased()
            return StationsDirectory.globalStationDirectory.filter { station in
                station.name.lowercased().contains(lowercasedQuery) ||
                station.country.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    func getPopularStations() async throws -> [RadioStation] {
        // Return the full directory as the default/popular list
        print("Returning full station directory.")
        return StationsDirectory.globalStationDirectory
    }
    
    func createCustomStation(url: URL, name: String) -> RadioStation {
        return RadioStation(
            name: name,
            url: url,
            country: "Custom",
            language: "Unknown",
            type: .directStream
        )
    }
    
    func validateStreamURL(_ url: URL) async -> Bool {
        // Check if it's a Radio Garden URL - NOTE: Validation doesn't mean playable
        if url.host?.contains("radio.garden") == true {
             print("Detected Radio Garden URL type. Validation skipped as playback requires stream extraction.")
            return true // Mark as 'valid' for now, but playback logic needs to handle it
        }
        
        // For direct streams, try to make a HEAD request to check if it's accessible
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        // Add a timeout
        request.timeoutInterval = 5 // 5 seconds timeout
        
        do {
            print("Validating direct stream URL: \(url)")
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Validation response status code: \(httpResponse.statusCode)")
                // Accept any 2xx or 3xx (redirects) status code as potentially valid
                return (200...399).contains(httpResponse.statusCode)
            }
        } catch let error as NSError {
            print("Error validating stream URL \(url): \(error.localizedDescription) (Code: \(error.code))")
             // Specifically handle timeout
            if error.code == NSURLErrorTimedOut {
                print("Validation timed out.")
            } else if error.code == NSURLErrorCannotFindHost {
                print("Validation failed: Host not found.")
            }
        }
        
        return false
    }
    
    // MARK: - Favorites Management
    
    func getFavorites() -> [RadioStation] {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode([RadioStation].self, from: data) {
            return favorites
        }
        return []
    }
    
    func addFavorite(_ station: RadioStation) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.url == station.url }) {
            favorites.append(station)
            saveFavorites(favorites)
        }
    }
    
    func removeFavorite(_ station: RadioStation) {
        var favorites = getFavorites()
        favorites.removeAll { $0.url == station.url }
        saveFavorites(favorites)
    }
    
    private func saveFavorites(_ favorites: [RadioStation]) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
} 
