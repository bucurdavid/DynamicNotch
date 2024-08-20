import SwiftUI
import ColorfulX

struct CurrentMediaPlayerView: View {
    @ObservedObject var mediaPlayer: CurrentMediaPlayer

    var body: some View {
        mediaPlayerArea
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(Color.black.opacity(0.5)) // Ensure background is consistent with TrayView
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the view uses all available space
    }
    
    var mediaPlayerArea: some View {
        VStack {
            Spacer() // Add a spacer to push the content down slightly, centering it vertically
            mediaLabel
            Spacer() // Add another spacer to keep the content centered vertically

            HStack(spacing: 20) {
                Button(action: {
                    mediaPlayer.previousTrack()
                }) {
                    Image(systemName: "backward.fill")
                }.buttonStyle(PlainButtonStyle())

                Button(action: {
                    mediaPlayer.playPause()
                }) {
                    Image(systemName: "playpause.fill")
                }.buttonStyle(PlainButtonStyle())

                Button(action: {
                    mediaPlayer.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 5)
        }
        .padding()
    }
    
    var mediaLabel: some View {
        VStack(spacing: 5) {
            Image(nsImage: mediaPlayer.currentArtwork ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70) // Adjust the size as needed
                .cornerRadius(9)

            Text(mediaPlayer.currentSongTitle)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            Text(mediaPlayer.currentArtist)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity) // Ensure the label takes the full width of the parent
        .multilineTextAlignment(.center) // Center the text within the label
    }
}

#Preview {
    CurrentMediaPlayerView(mediaPlayer: CurrentMediaPlayer())
}
