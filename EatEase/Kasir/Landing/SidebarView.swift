//
//  SidebarView.swift
//  EatEase
//
//  Created by Ilham Ramadhani on 31/05/25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowing: Bool // Untuk menutup sidebar

    private var userName: String {
        guard let email = authManager.userSession?.email else { return "Guest" }
        // Ambil bagian sebelum '@' dan kapitalkan huruf pertama
        return email.components(separatedBy: "@").first?.capitalized ?? email
    }
    
    private var userEmail: String {
        authManager.userSession?.email ?? "Tidak ada email"
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Header Sidebar
            VStack(alignment: .leading) {
                Image(systemName: "person.crop.circle.fill") // Placeholder avatar
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .padding(.top, 50) // Jarak dari atas status bar

                Text(userName)
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)
                
                Text(userEmail)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Daftar Menu Sidebar (bisa ditambahkan nanti)
            // Contoh:
            // Button(action: { /* Aksi menu 1 */ isShowing = false }) {
            //     HStack {
            //         Image(systemName: "gear")
            //         Text("Pengaturan")
            //     }
            // }
            // .padding()

            Spacer() // Mendorong tombol logout ke bawah

            // Tombol Logout
            Button(action: {
                authManager.signOut()
                isShowing = false // Tutup sidebar setelah logout
            }) {
                HStack {
                    Image(systemName: "arrow.backward.square.fill")
                    Text("Logout")
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading) // Agar teks rata kiri
            }
            .padding(.bottom, 30) // Jarak dari bawah
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Sidebar mengambil lebar penuh yang tersedia
        .background(Color(.systemBackground)) // Warna background sidebar
        .edgesIgnoringSafeArea(.top) // Bisa juga .all jika ingin full
    }
}

// Preview untuk SidebarView
struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        // Buat mock authManager untuk preview
        let mockAuthManager = AuthenticationManager()
        // Anda bisa set mock user session di sini jika ingin melihat nama dan email
        // Contoh: (membutuhkan cara untuk membuat mock Firebase.User)
        // class MockUser: FirebaseAuth.User { /* ... implementasi minimal ... */ }
        // mockAuthManager.userSession = MockUser()

        SidebarView(isShowing: .constant(true))
            .environmentObject(mockAuthManager)
            .frame(width: 250) // Beri lebar pada preview agar terlihat
    }
}
