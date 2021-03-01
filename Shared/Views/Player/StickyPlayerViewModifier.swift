//
//  StickyPlayerViewModifier.swift
//  Pimpster
//
//  Created by Oleg Soldatoff on 1.03.21.
//

import SwiftUI

struct StickyPlayerViewModifier: ViewModifier {
    @EnvironmentObject var playerBrain: PlayerBrain
    func body(content: Content) -> some View {
        VStack{
            content
            StickyPlayerView()
        }
    }
}
