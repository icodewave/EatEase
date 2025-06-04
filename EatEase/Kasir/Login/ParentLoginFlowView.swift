//
//  ParentLoginFlowView.swift
//  EatEase
//
//  Created by iCodeWave Community on 04/06/25.
//

import SwiftUI

struct ParentLoginFlowView: View {
    // Menggunakan @EnvironmentObject untuk mendapatkan instance AuthenticationManager
    // yang sudah dibuat di RootView. Ini adalah cara yang direkomendasikan
    // untuk meneruskan ObservableObject ke sub-view dalam hierarki.
    @EnvironmentObject var authManager: AuthenticationManager

    // State untuk mengontrol apakah WelcomeScreen masih ditampilkan atau sudah beralih ke LoginView.
    // Defaultnya true, agar WelcomeScreen muncul pertama kali.
    @State private var showWelcomeScreen = true

    var body: some View {
        // Cek status otentikasi. Jika user sudah login, langsung ke LandingPageView.
        // Ini adalah fallback safety net, meskipun RootView seharusnya sudah menanganinya.
        if authManager.userSession != nil {
            LandingPageView()
                // Penting: Teruskan authManager ke LandingPageView juga
                // agar LandingPageView dan sub-view-nya bisa mengakses status login atau logout.
                .environmentObject(authManager)
        } else {
            // Jika user belum login, tampilkan alur login.
            // Gunakan if-else untuk beralih antara WelcomeScreen dan LoginView.
            if showWelcomeScreen {
                // Tampilkan WelcomeScreen.
                // showLogin di WelcomeScreen adalah @Binding, jadi kita lewatkan $showWelcomeScreen.
                // Ketika showLogin di WelcomeScreen berubah menjadi true (setelah swipe up),
                // maka state showWelcomeScreen di ParentLoginFlowView ini juga akan berubah,
                // memicu render ulang dan menampilkan LoginView.
                WelcomeScreen(showLogin: $showWelcomeScreen)
                    // Transisi visual saat WelcomeScreen muncul.
                    .transition(.move(edge: .bottom)) // Opsi: .opacity, .scale, dll.
            } else {
                // Tampilkan LoginView.
                // authManager diteruskan ke LoginView agar LoginViewModel bisa menggunakannya.
                LoginView(authManager: authManager)
                    // Transisi visual saat LoginView muncul (setelah WelcomeScreen menghilang).
                    .transition(.move(edge: .bottom)) // Konsisten dengan WelcomeScreen
            }
        }
    }
}

// Preview untuk ParentLoginFlowView
struct ParentLoginFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ParentLoginFlowView()
            // Untuk preview, sediakan AuthenticationManager dummy atau asli
            .environmentObject(AuthenticationManager())
    }
}
