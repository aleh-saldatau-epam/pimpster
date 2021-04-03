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
                PlayerInternalView(state: .compact)
            }
        }
    }
}

struct PlayerInternalView: View {
    enum PlayerState {
        case compact
        case expanded
    }
    @State var state: PlayerState = .compact
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        VStack {
            TopPlayerSubview(state: $state)
            TitlePlayerSubview()
            MoreInfoPlayerSubview(state: $state)
            ControlsPlayerSubview()
            ProgressInfoPlayerSubview()
        }
    }
}

struct TitlePlayerSubview: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        if let title = playerBrain.playableItem?.title {
            Text(title)
        }
    }
}

struct MoreInfoPlayerSubview: View {
    @Binding var state: PlayerInternalView.PlayerState
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        switch state {
        case .compact:
            EmptyView()
        case .expanded:
            VStack {
                if let description = playerBrain.playableItem?.description {
                    Text(description)
                }
                ImageFromURLView(imageLoader: ImageLoader(urlString: playerBrain.playableItem?.imageUrlString))
            }
        }
    }
}

struct ControlsPlayerSubview: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        HStack {
            Spacer()
            Button("-15 secs", action: { self.playerBrain.updateProgress(by: -15) })
            Spacer()
            PlayPauseButton()
            Spacer()
            Button("+15 secs", action: { self.playerBrain.updateProgress(by: 15) })
            Spacer()
        }
    }
}

struct TopPlayerSubview: View {
    @Binding var state: PlayerInternalView.PlayerState
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        HStack {
            Spacer()
            switch state {
            case .compact:
                Button(action: { self.state = .expanded }, label: { Image(systemName: "chevron.compact.up") })
            case .expanded:
                Button(action: { self.state = .compact }, label: { Image(systemName: "chevron.compact.down") })
            }
            Spacer()
            Button(action: { playerBrain.playableItem = nil }, label: { Image(systemName: "xmark.circle.fill") })
        }
    }
}

struct ProgressInfoPlayerSubview: View {
    var body: some View {
        HStack {
            CurrentProgressPlayerSubview()
            SliderPlayerSubview()
            DurationPlayerSubview()
        }
    }
}

struct SliderPlayerSubview: View {
    @EnvironmentObject var playerBrain: PlayerBrain
    var body: some View {
        switch playerBrain.currentTime {
        case .some:
            // https://medium.com/flawless-app-stories/avplayer-swiftui-part-2-player-controls-c28b721e7e27
            Slider(value: $playerBrain.progress, in: 0...1) { (changed) in
                // Slider updates progress and method below considers this
                self.playerBrain.updateProgress(by: nil)
            }
        case .none:
            Color.clear
        }
    }
}

struct CurrentProgressPlayerSubview: View {
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

struct DurationPlayerSubview: View {
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
                Text("Loading...")
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

