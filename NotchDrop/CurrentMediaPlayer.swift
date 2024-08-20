import Cocoa
import Foundation

class CurrentMediaPlayer: NSObject, ObservableObject {
    @Published var currentSongTitle: String = ""
    @Published var currentArtist: String = ""
    @Published var currentAlbum: String = ""
    @Published var currentDuration: String = ""
    @Published var currentArtwork: NSImage? = nil
    @Published var isPlaying: Bool = false

    override init() {
        super.init()
        registerForNowPlayingNotifications()
        fetchNowPlayingInfo()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerForNowPlayingNotifications() {
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            return
        }

        // Register for now playing notifications
        guard let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) else { return }
        typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
        let MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)

        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)

        // Subscribe to notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchNowPlayingInfo),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil
        )
    }

    @objc func fetchNowPlayingInfo() {
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            return
        }

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        // Get song info
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] (information) in
            guard let self = self else { return }
            self.currentArtist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "Unknown Artist"
            self.currentSongTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "Unknown Title"
            self.currentAlbum = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? "Unknown Album"
            self.currentDuration = String(information["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0.0)
            if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                self.currentArtwork = NSImage(data: artworkData)
            }

            // Check playback rate to determine if music is playing
            if let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
                self.isPlaying = playbackRate > 0.0
             
            } else {
                self.isPlaying = false
            }
 
 
        }
    }

    // MARK: - Media Controls

    func playPause() {
        let MRMediaRemoteSendCommand = MediaRemoteProxy.proxyMRMediaRemoteSendCommand()
        _ = MRMediaRemoteSendCommand?(2, nil)
    }

    func nextTrack() {
        let MRMediaRemoteSendCommand = MediaRemoteProxy.proxyMRMediaRemoteSendCommand()
        _ = MRMediaRemoteSendCommand?(4, nil)
    }

    func previousTrack() {
        let MRMediaRemoteSendCommand = MediaRemoteProxy.proxyMRMediaRemoteSendCommand()
        _ = MRMediaRemoteSendCommand?(5, nil)
    }
}

final class MediaRemoteProxy {
    private static let mediaRemoteBundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
    
    typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int, AnyObject?) -> Bool
    
    static func proxyMRMediaRemoteSendCommand() -> MRMediaRemoteSendCommandFunction? {
        guard let pointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteSendCommand" as CFString) else {
            return nil
        }
        return unsafeBitCast(pointer, to: MRMediaRemoteSendCommandFunction.self)
    }
}
