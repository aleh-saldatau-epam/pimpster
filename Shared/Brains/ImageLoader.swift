//
//  ImageLoader.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 12.02.21.
//

import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published private(set) var state = LoadingState.idle

    let urlString: String?
    var imageData: Data? // to work on mac OS

    init(urlString: String?) {
        self.urlString = urlString
    }

    private var cancellable: AnyCancellable?

    func loadImage() {
        state = .loading
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            state = .failed(nil)
            return
        }

        cancellable = URLSession
            .shared
            .dataTaskPublisher(for: url)
//            .receive(on: RunLoop.main) // Inspect
            .map {  // Type returned here has impact on receiveValue in sink
                $0.data
            }
            .receive(on: RunLoop.main) // Inspect
            .sink(
                receiveCompletion: { [weak self] result in
                    // result is
                    // Subscribers.Completion<URLSession.DataTaskPublisher.Failure>
                    // (aka 'Subscribers.Completion<URLError>')
                    // https://developer.apple.com/documentation/combine/subscribers/completion
                    switch result {
                        case .finished:
                            self?.state = .loaded
                        case .failure(let failure): //URLSession.DataTaskPublisher.Failure
                            self?.state = .failed(failure)
                    }
                    print("receiveCompletion")
                },
                receiveValue: { [weak self] in
                    self?.imageData = $0
                    print("receiveValue")
                }
            )
    }
}
