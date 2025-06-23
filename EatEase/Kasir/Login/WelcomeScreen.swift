//
//  WelcomeScreen.swift
//  EatEase
//
//  Created by iCodeWave Community on 04/06/25.
//

// WelcomeScreen.swift

import SwiftUI

struct WelcomeScreen: View {
    // Binding ini akan digunakan untuk berkomunikasi dengan parent view (misalnya ParentLoginFlowView)
    // agar parent view tahu kapan harus beralih ke LoginView.
    @Binding var showLogin: Bool // Di ParentLoginFlowView, ini terikat dengan showWelcomeScreen

    var body: some View {
        ZStack {
            // Latar belakang gradasi
            LinearGradient(gradient: Gradient(colors: [
                Color.blue,  
                Color.white
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer() // Mendorong konten ke tengah/atas
                
                Image(systemName: "frying.pan.fill") // Contoh ikon SF Symbols
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) // Ukuran bisa disesuaikan
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 50) // Jarak di bawah gambar
                
                Text("Swipe up to explore your EatEase.")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Indikator visual untuk swipe up (panah ke atas)
                Image(systemName: "chevron.compact.up") // Menggunakan chevron.compact.up untuk tampilan yang lebih subtle
                    .font(.system(size: 60)) // Ukuran font disesuaikan
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 60)
                    // Animasi naik turun sederhana
                    .modifier(ShakeEffect(shakes: showLogin ? 0 : 1)) // Contoh animasi sederhana
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showLogin)


                Spacer() // Mendorong konten ke tengah/bawah
            }
        }
        // Gesture recognizer untuk mendeteksi swipe ke atas
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local) // minimumDistance agar swipe pendek tidak terdeteksi
                .onEnded { value in
                    print("Swipe detected. Vertical translation: \(value.translation.height)")
                    // Cek apakah swipe ke atas dan cukup signifikan
                    if value.translation.height < -50 { // -50 adalah ambang batas, bisa disesuaikan
                        print("Swipe up threshold met! Changing showLogin (bound to showWelcomeScreen) to false.")
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { // Animasi transisi yang lebih menarik
                            // Mengubah showLogin menjadi false akan memberitahu ParentLoginFlowView
                            // untuk berhenti menampilkan WelcomeScreen dan menampilkan LoginView.
                            self.showLogin = false
                        }
                    }
                }
        )
    }
}

// Modifier untuk animasi naik turun sederhana (opsional)
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    init(shakes: Int) {
        animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 0,
            y: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))))
    }
}


// Preview untuk memudahkan desain WelcomeScreen di Xcode Canvas
struct WelcomeScreen_Previews: PreviewProvider {
    @State static var previewShowLogin = true // Ubah ke true untuk melihat efek awal
    static var previews: some View {
        WelcomeScreen(showLogin: $previewShowLogin)
    }
}
