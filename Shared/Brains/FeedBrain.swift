//
//  FeedBrain.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 11.02.21.
//

import FeedKit
import SwiftUI

extension RSSFeedItem: Hashable {
    static func ==(lhs: RSSFeedItem, rhs: RSSFeedItem) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

// https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/
enum LoadingState {
    case idle
    case loading
    case failed(Error?)
    case loaded
}

class FeedBrain: ObservableObject {
    let urlStr: String
    @Published private(set) var state = LoadingState.idle
    private(set) var feed: RSSFeed = RSSFeed() {
        didSet {
            print("did set")
        }
    }

    init(urlStr: String) {
        self.urlStr = urlStr
    }

    func resetStateToIdleIfNeeded() {
        if case LoadingState.loaded = state {
            state = .idle
        }
    }

    func loadFeed() {
        state = .loading

        guard let url = URL(string: urlStr) else {
            state = .failed(nil)
            return
        }

        let parser = FeedParser(URL: url)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { [weak self] (result) in
            switch result {
            case .success(let feed):
                if let rssFeed = feed.rssFeed {
                    self?.feed =  rssFeed
                    self?.setOnMainThread(newState: .loaded)
                }
            case .failure(let error):
                print(error)
                self?.feed =  RSSFeed()
                self?.setOnMainThread(newState: .failed(error))
            }
        }
    }

    private func setOnMainThread(newState: LoadingState) {
        DispatchQueue.main.async { [weak self] in
            self?.state = newState
        }
    }
}
