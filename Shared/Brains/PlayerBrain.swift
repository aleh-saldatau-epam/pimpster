//
//  PlayerBrain.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 13.02.21.
//

import AVFoundation
import Combine
import FeedKit

enum PlayerVisibility {
    case hidden
    case visible
}

class PlayerBrain: ObservableObject {
    @Published var visibility: PlayerVisibility = .hidden
    @Published var currentStatus: AVPlayer.TimeControlStatus?
    @Published var itemDuration: CMTime?
    @Published var currentTime: CMTime?
    @Published var progress: Double = 0.0

    private (set) var player: AVPlayer?
    private var observationItems = [AnyCancellable?]()

    var item: RSSFeedItem? {
        didSet {
            observationItems.removeAll()
            let url = item?.media?.mediaContents?.first?.attributes?.url
            print( url ?? "No url")
            guard let urlString = url,
                  let actualURL = URL(string: urlString) else {
                player = nil
                visibility = .hidden
                return
            }
            visibility = .visible

            let item = AVPlayerItem(url: actualURL)
            player = AVPlayer(playerItem: item)
            player?.volume = 1.0
            player?.play()

            let timeControlStatusObservation = player?
                .publisher(for: \.timeControlStatus)
                .sink(receiveValue: { [weak self] (newStatus) in
                    self?.currentStatus = newStatus
                })
            observationItems.append(timeControlStatusObservation)

            let itemDurationObservation = player?
                .currentItem?
                .publisher(for: \.duration)
                .sink(receiveValue: { [weak self] (newDuration) in
                    self?.itemDuration = newDuration
                })
            observationItems.append(itemDurationObservation)

            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil, using: { [weak self] (newCurrentTime) in
                self?.currentTime = newCurrentTime
                self?.progress = newCurrentTime.seconds / (self?.itemDuration?.seconds ?? 0.0)
            })
        }
    }

    func timeInProperFormat(time: CMTime?) -> String {
        guard let seconds = time?.seconds, !seconds.isNaN else {
            return ""
        }
        let time = DateComponentsFormatter().string(from: seconds.rounded()) ?? ""
        return time

    }

    func togglePlayPause() {
        if player?.timeControlStatus == .playing {
            player?.pause()
        } else {
            player?.play()
        }
    }
}
