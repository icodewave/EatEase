import SwiftUI

struct RootView: View {
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        Group {
            if authManager.userSession != nil {
                LandingPageView()
                    .environmentObject(authManager)
            } else {
                // Langsung tampilkan LoginView karena Loginscreen.swift sudah dihapus
//                LoginView(authManager: authManager)
                ParentLoginFlowView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            print("RootView appeared. Current user: \(authManager.userSession?.uid ?? "None")")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
