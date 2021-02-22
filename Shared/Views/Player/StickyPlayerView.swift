//
//  StickyPlayerView.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 13.02.21.
//

import AVFoundation
import SwiftUI

struct StickyPlayerView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        Group {
            switch playerBrain.visibility {
            case .hidden:
                Color.clear.frame(width: 0, height: 0)
            case .visible:
                VStack {
                    Text("Player")
                    PlayPauseButton()
                    HStack {
                        CurrentProgressView()
                        SliderView()
                        DurationView()
                    }
                }
            }
        }
    }
}

struct SliderView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        switch playerBrain.currentTime {
        case .some:
            // https://medium.com/flawless-app-stories/avplayer-swiftui-part-2-player-controls-c28b721e7e27
            Slider(value: $playerBrain.progress, in: 0...1) { (changed) in
                guard let item = self.playerBrain.player?.currentItem else {
                    return
                }
                let targetTime = self.playerBrain.progress * item.duration.seconds
                self.playerBrain.player?.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
            }
        case .none:
            Color.clear
        }
    }
}

struct CurrentProgressView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        switch playerBrain.currentTime {
        case .some:
            Text(playerBrain.timeInProperFormat(time: playerBrain.currentTime))
        case .none:
            Color.clear
        }
    }
}

struct DurationView: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        switch playerBrain.itemDuration {
        case .some:
            Text(playerBrain.timeInProperFormat(time: playerBrain.itemDuration))
        case .none:
            Color.clear
        }
    }
}

struct PlayPauseButton: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        HStack {
            switch playerBrain.currentStatus {
            case .playing:
//                Text("playing")
                Button("Pause", action: playerBrain.togglePlayPause)
            case .paused:
//                Text("paused")
                Button("Play", action: playerBrain.togglePlayPause)
            case .waitingToPlayAtSpecifiedRate:
                Text("waitingToPlayAtSpecifiedRate")
            case .none:
                Text("none")
            @unknown default:
                Text("unknown default")
            }
        }
    }
}

struct StickyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        StickyPlayerView()
    }
}
