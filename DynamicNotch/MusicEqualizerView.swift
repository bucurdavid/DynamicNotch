import SwiftUI

struct MusicEqualizerView: View {
    @State private var animationAmount: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(Color.white)
                    .frame(width: 3, height: CGFloat.random(in: 4...10) * animationAmount)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                        value: animationAmount
                    )
            }
        }
        .onAppear {
            animationAmount = 1.5
        }
    }
}
