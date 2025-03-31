import Foundation

// Static directory of known accessible radio streams
struct StationsDirectory {
    static let globalStationDirectory: [RadioStation] = [
        // --- Ambient / Chillout / Electronic --- 
        RadioStation(name: "SomaFM - Groove Salad", url: URL(string: "https://ice6.somafm.com/groovesalad-128-mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "SomaFM - Drone Zone", url: URL(string: "https://ice6.somafm.com/dronezone-128-mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "SomaFM - Lush", url: URL(string: "https://ice6.somafm.com/lush-128-mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Radio Paradise - Mellow Mix", url: URL(string: "https://stream.radioparadise.com/mellow-192")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Chillkyway Radio", url: URL(string: "https://streams.chillkyway.com/radio/8000/radio.mp3")!, country: "Germany", language: "Instrumental", type: .directStream),
        RadioStation(name: "Ibiza Global Radio", url: URL(string: "https://listenssl.ibizaglobalradio.com:8024/live.mp3")!, country: "Spain", language: "Spanish/English", type: .directStream),
        
        // --- Rock / Alternative / Indie --- 
        RadioStation(name: "Radio Paradise - Rock Mix", url: URL(string: "https://stream.radioparadise.com/rock-192")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "KEXP 90.3 FM", url: URL(string: "https://kexp-mp3-128.streamguys1.com/kexp128.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "The Current 89.3 FM", url: URL(string: "https://current.stream.publicradio.org/kcmp.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Indie88", url: URL(string: "https://stream.indie88.com/indie88")!, country: "Canada", language: "English", type: .directStream),
        RadioStation(name: "FluxFM (Berlin)", url: URL(string: "https://stream.fluxfm.de/fluxfm/mp3-320/streams.fluxfm.de/")!, country: "Germany", language: "German", type: .directStream),
        RadioStation(name: "Radio X (UK)", url: URL(string: "https://media-ssl.musicradio.com/RadioXLondon?device=uk.co.radiox&listen=live&app_id=1")!, country: "UK", language: "English", type: .directStream), // May have geo-fencing sometimes
        
        // --- Jazz / Blues / Classical --- 
        RadioStation(name: "WBGO Jazz 88.3 FM", url: URL(string: "https://wbgo.streamguys.net/wbgo128")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "KMHD Jazz Radio", url: URL(string: "https://ais-sa1.streamon.fm/7007_128k.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Linn Jazz (UK)", url: URL(string: "https://stream.linn.co.uk/stream/jazz/aac")!, country: "UK", language: "Instrumental", type: .directStream), // AAC stream
        RadioStation(name: "Linn Classical (UK)", url: URL(string: "https://stream.linn.co.uk/stream/classical/aac")!, country: "UK", language: "Instrumental", type: .directStream), // AAC stream
        RadioStation(name: "WCPE The Classical Station", url: URL(string: "https://audio-mp3.wcpe.org/wcpe.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Venice Classic Radio", url: URL(string: "https://www.veniceclassicradio.eu/radio/vcr320.mp3")!, country: "Italy", language: "Instrumental", type: .directStream),
        
        // --- World / Folk / Country --- 
        RadioStation(name: "Radio New Zealand National", url: URL(string: "https://radionz.streamguys1.com/national/national_128kbps")!, country: "New Zealand", language: "English", type: .directStream),
        RadioStation(name: "FIP (France)", url: URL(string: "https://stream.radiofrance.fr/fip/fip_hifi.m3u8")!, country: "France", language: "French", type: .directStream), // HLS Stream (might test AVPlayer limit)
        RadioStation(name: "RTE Radio 1 (Ireland)", url: URL(string: "https://rteradio1-lh.akamaihd.net/i/rteradio1_1@329718/master.m3u8")!, country: "Ireland", language: "English", type: .directStream), // HLS Stream
        RadioStation(name: "KUTX 98.9 (Austin)", url: URL(string: "https://kut.stream.publicradio.org/kutx_live.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "Bluegrass Country", url: URL(string: "https://audio-mp3.bluegrasscountry.org/bluegrass.mp3")!, country: "USA", language: "English", type: .directStream),
        
        // --- Pop / Top 40 / Various --- 
        // Note: Many Top 40 streams are heavily geo-restricted or use proprietary players
        RadioStation(name: "Hitradio OE3 (Austria)", url: URL(string: "https://orf-live.ors-shoutcast.at/oe3-128a.mp3")!, country: "Austria", language: "German", type: .directStream),
        RadioStation(name: "NRJ (France)", url: URL(string: "https://scdn.nrjaudio.fm/fr/30001/mp3_128.mp3?origine=fluxradios")!, country: "France", language: "French", type: .directStream),
        RadioStation(name: "KIIS 102.7 FM (LA)", url: URL(string: "https://stream.revma.ihrhls.com/zc185")!, country: "USA", language: "English", type: .directStream), // iHeart stream, might be less stable
        RadioStation(name: "WFMU 91.1 FM", url: URL(string: "https://stream0.wfmu.org/freeform-128k")!, country: "USA", language: "English", type: .directStream), // Freeform
        RadioStation(name: "NTS Radio 1 (London)", url: URL(string: "https://stream-relay-geo.ntslive.net/stream")!, country: "UK", language: "English", type: .directStream), // Diverse Electronic/Experimental
        RadioStation(name: "181.FM - Power 181 (Top 40)", url: URL(string: "https://listen.181fm.com/181-power_128k.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "181.FM - The Beat (HipHop/R&B)", url: URL(string: "https://listen.181fm.com/181-beat_128k.mp3?aw_0_1st.collectionid=1402&stationId=192")!, country: "USA", language: "English", type: .directStream),
        
        // --- News / Talk --- 
        RadioStation(name: "NPR News/Talk (Program Stream)", url: URL(string: "https://npr-ice.streamguys1.com/live.mp3")!, country: "USA", language: "English", type: .directStream),
        RadioStation(name: "WNYC 93.9 FM (New York)", url: URL(string: "https://fm939.wnyc.org/wnycfm-mobile?type=.aac")!, country: "USA", language: "English", type: .directStream), // AAC stream
        RadioStation(name: "BBC World Service (English)", url: URL(string: "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service")!, country: "UK", language: "English", type: .directStream), // Often works where Radio 1 fails
        RadioStation(name: "CBC Radio One (Toronto)", url: URL(string: "https://cbc_r1_tor.akacast.akamaistream.net/7/632/451661/v1/rc.akacast.akamaistream.net/cbc_r1_tor")!, country: "Canada", language: "English", type: .directStream)
        
        // Add ~150 more diverse stations here... (truncated for brevity)
        // ... Example structure repeated ...
    ]
}
