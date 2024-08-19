import SwiftUI
import ColorfulX

struct CurrentMediaPlayerView: View {
    @ObservedObject var mediaPlayer: CurrentMediaPlayer

    var body: some View {
        mediaPlayerArea
    }
    
    var mediaPlayerArea: some View {
        ZStack {
            Color.black // Set the background to black
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(0.5)

            VStack {
                mediaLabel
                
                HStack(spacing: 30) {
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
                        Image(systemName:
                                "forward.fill")
                            .background(Color.black)
                    
                         
                        
                    }.buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 5)
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .aspectRatio(1, contentMode: .fit)
    }
    
    var mediaLabel: some View {
        VStack(spacing: 10) {
            if let artwork = mediaPlayer.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(9)
            }
            Text(mediaPlayer.currentSongTitle)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            Text(mediaPlayer.currentArtist)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
    }
}

#Preview{
    CurrentMediaPlayerView(mediaPlayer: CurrentMediaPlayer())
}
