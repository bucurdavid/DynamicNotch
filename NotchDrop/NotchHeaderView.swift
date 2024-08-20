import ColorfulX
import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel
    @State private var greeting: String = ""

    var body: some View {
        HStack {
            Text(vm.contentType == .settings ? versionInfo : greeting)
                .contentTransition(.numericText())
            Spacer()
            Image(systemName: "ellipsis")
        }
        .animation(vm.animation, value: vm.contentType)
        .font(.system(.headline, design: .rounded))
        .onAppear {
            updateGreeting()
        }
    }

    private var versionInfo: String {
        "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))"
    }

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = "David" // Replace with dynamic name if available

        switch hour {
        case 0..<12:
            greeting = "Good morning, \(name)"
        case 12..<17:
            greeting = "Good afternoon, \(name)"
        case 17..<24:
            greeting = "Good evening, \(name)"
        default:
            greeting = "Hello, \(name)"
        }
    }
}

#Preview {
    NotchHeaderView(vm: .init())
}
