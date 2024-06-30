//
//  VideoPlayerView.swift
//  VideoFeed
//
//  Created by Abouzar Moradian on 4/23/24.
//

import SwiftUI
import AVFoundation
import AVKit



struct VideoPlayerWrapper1: UIViewControllerRepresentable {
    let url: URL
    let aspectRatio: CGFloat
    let postIndex: Int
    let slideIndex: Int
    @Binding var playedPostIndex: Int
    @Binding var currentSlide: Int
    @Binding var isPlaying: Bool
    @Binding var isMute: Bool
    
    
    @State private var previousSatisfied: Bool = true
    @State private var previousIsPlaying: Bool = false
    
    
    func makeUIViewController(context: Context) -> VideoPlayerViewClass1 {
        let viewController = VideoPlayerViewClass1(aspectRatio: aspectRatio, isPlaying: $isPlaying , url: url)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewClass1, context: Context) {
        
        if isMute{
            uiViewController.player.isMuted = true
        }else{
            uiViewController.player.isMuted = false
            
        }
        
        
        if previousIsPlaying != isPlaying{
            print("is playing changed: \(isPlaying)")
            if isPlaying  && (playedPostIndex == postIndex && currentSlide == slideIndex ){
                uiViewController.seekToZeroAndPlay()
                
            }
            DispatchQueue.main.async{
                previousIsPlaying = isPlaying
                
            }
            
        }
        
        
        if (previousSatisfied != (playedPostIndex == postIndex && currentSlide == slideIndex ))  {
            
            DispatchQueue.main.async{
                
                previousSatisfied =  (playedPostIndex == postIndex && currentSlide == slideIndex)
            }
            
            if playedPostIndex == postIndex && currentSlide == slideIndex  {
                
                print("is playing true inside wrapper")
                uiViewController.seekToZeroAndPlay()
            } else {
                
                print("is playing false inside wrapper")
                uiViewController.seekToZeroAndPause()
            }
            
            
        }
    }
}



struct VideoPlayerWrapper: UIViewControllerRepresentable {
    let player: AVPlayer
    let aspectRatio: CGFloat
  
    @Binding var isPlaying: Bool
    
    @State private var previousIsPlaying: Bool = false // State to track previous value
    
    func makeUIViewController(context: Context) -> VideoPlayerViewClass {
        let viewController = VideoPlayerViewClass(player: player, aspectRatio: aspectRatio, isPlaying: $isPlaying)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewClass, context: Context) {
        
  
    }
}



class VideoPlayerViewClass1: UIViewController, UIScrollViewDelegate {
    
    var avPlayerViewController: AVPlayerViewController!
    var tapGesture: UITapGestureRecognizer!
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    let aspectRatio: CGFloat
    var isPlaying: Binding<Bool> // Added this line
    let url: URL
    
    
    init(aspectRatio: CGFloat, isPlaying: Binding<Bool>, url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: player)
        self.aspectRatio = aspectRatio
        self.isPlaying = isPlaying
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure AVAudioSession for audio playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
        
        setupPlayer()
    }
    
    func setupPlayer() {
        // Observe when the video reaches the end
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        print("Notification observer added")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width / aspectRatio)
        view.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width / aspectRatio)
        
        //player.play()
        //player.isMuted = true
        DispatchQueue.main.async {
            self.isPlaying.wrappedValue = true
        }
    }
    
    
    
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        
        // Ensure the player item is ready
        guard playerItem.status == .readyToPlay else {
            print("Error: Player item is not ready to play")
            return
        }
        
        // Seek to the beginning
        playerItem.seek(to: CMTime.zero) { [weak self] success in
            if success {
                
                if self?.player.status == .readyToPlay {
                    
                    self?.isPlaying.wrappedValue = false
                } else {
                    print("Error: Player is not ready to play")
                }
            } else {
                print("Error: Seek operation failed")
            }
        }
    }
    
    func seekToZeroAndPlay(){
        print("seek to zero is callled")
        guard let playerItem = player.currentItem else { return }
        
        playerItem.seek(to: CMTime.zero) { [weak self] success in
            if success {
                if self?.player.rate == 0{
                    self?.player.play()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        
                        self?.isPlaying.wrappedValue = true
                        //self?.player.isMuted = false
                    }
                }
            }  else {
                print("Error: Seek operation failed")
            }
            
        }
    }
    
    
    func seekToZeroAndPause(){
        print("seek to zero is callled")
        guard let playerItem = player.currentItem else { return }
        
        self.player.pause()
        
        DispatchQueue.main.async {
            self.isPlaying.wrappedValue = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            
            
            playerItem.seek(to: CMTime.zero) { [weak self] success in
                if success {
                    
                    
                }  else {
                    print("Error: Seek operation failed")
                }
                
            }
        }
    }
    
    
    
    
    func play() {
        playerLayer.player = nil
        playerLayer.player = player
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player.play()
        }
        
        
    }
    
    
    
    func pause() {
        self.player.pause()
        print("pause is callled")
        
    }
    
   
}



import SwiftUI
import AVKit

struct myVideoPlayer: UIViewControllerRepresentable {
    
    let player: AVPlayer
    
    
    
    func makeUIViewController(context:
                              
                              
                              
                              UIViewControllerRepresentableContext<myVideoPlayer>) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: AVPlayerViewController,
        context: UIViewControllerRepresentableContext<myVideoPlayer>
    ) {
    }
}






class VideoPlayerViewClass: UIViewController, UIScrollViewDelegate {
    
    var avPlayerViewController: AVPlayerViewController!
    var tapGesture: UITapGestureRecognizer!
    var player: AVPlayer
    var playerLayer: AVPlayerLayer
    let aspectRatio: CGFloat
    var isPlaying: Binding<Bool> // Added this line
    
    
    init(player: AVPlayer, aspectRatio: CGFloat, isPlaying: Binding<Bool>) { // Modified initializer
        self.player = player
        self.playerLayer = AVPlayerLayer(player: player)
        self.aspectRatio = aspectRatio
        self.isPlaying = isPlaying // Set the binding
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure AVAudioSession for audio playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
        
        setupPlayer()
    }
    
    func setupPlayer() {
        // Observe when the video reaches the end
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        print("Notification observer added")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width / aspectRatio)
        view.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width / aspectRatio)
        
        //player.play()
        // player.isMuted = true
        DispatchQueue.main.async {
            self.isPlaying.wrappedValue = true
        }
    }
    
    
    
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else { return }
        
        // Ensure the player item is ready
        guard playerItem.status == .readyToPlay else {
            print("Error: Player item is not ready to play")
            return
        }
        
        // Seek to the beginning
        playerItem.seek(to: CMTime.zero) { [weak self] success in
            if success {
                
                if self?.player.status == .readyToPlay {
                    
                    self?.isPlaying.wrappedValue = false
                } else {
                    print("Error: Player is not ready to play")
                }
            } else {
                print("Error: Seek operation failed")
            }
        }
    }
    
    func seekToZeroAndPlay(){
        print("seek to zero is callled")
        guard let playerItem = player.currentItem else { return }
        
        playerItem.seek(to: CMTime.zero) { [weak self] success in
            if success {
                if self?.player.rate == 0{
                    self?.player.play()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        
                        self?.isPlaying.wrappedValue = true
                        //self?.player.isMuted = false
                    }
                }
            }  else {
                print("Error: Seek operation failed")
            }
            
        }
    }
    
    
    func seekToZeroAndPause(){
        print("seek to zero is callled")
        guard let playerItem = player.currentItem else { return }
        
        self.player.pause()
        
        DispatchQueue.main.async {
            self.isPlaying.wrappedValue = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            
            
            playerItem.seek(to: CMTime.zero) { [weak self] success in
                if success {
                    
                    
                }  else {
                    print("Error: Seek operation failed")
                }
                
            }
        }
    }
    
    
    
    
    func play() {
        playerLayer.player = nil
        playerLayer.player = player
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.player.play()
        }
        
        
    }
    
    
    
    func pause() {
        self.player.pause()
        print("pause is callled")
        
    }
    
    
    
}

