// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import SwiftUI

struct LoopingPlayer: UIViewRepresentable {
    var viewModel: InterstitialViewModel?

    func makeUIView(context: Context) -> UIView {
        let view = QueuePlayerUIView(frame: .zero)
        viewModel?.player = view
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Do nothing here
    }
}

class QueuePlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Load Video
        let fileUrl = Bundle.main.url(
            forResource: "default-browser-animation", withExtension: "mp4")!
        let playerItem = AVPlayerItem(url: fileUrl)

        // Setup Player
        player = AVQueuePlayer(playerItem: playerItem)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        // Loop
        playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem)
        player!.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func play() {
        player?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LoopingPlayer_Previews: PreviewProvider {
    static var previews: some View {
        LoopingPlayer(viewModel: nil)
    }
}
