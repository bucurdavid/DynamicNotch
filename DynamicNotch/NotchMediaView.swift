import SwiftUI

struct NotchMediaView: View {
    @ObservedObject var mediaPlayer: CurrentMediaPlayer
 

    var body: some View {
        HStack(spacing: 16) {
            if let artwork = mediaPlayer.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25) // Match the height to the notch
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(Text("No Art").foregroundColor(.white).font(.caption))
            }

            Spacer()

            if mediaPlayer.isPlaying {
                MusicEqualizerView()
                    .frame(width: 20, height:20) // Match the height to the notch
            }
                
        }
    }
    
   
}
