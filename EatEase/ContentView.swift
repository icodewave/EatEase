import SwiftUI

struct ContentView: View {
    // Dapatkan authManager dari environment untuk fungsi logout
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack {
            Text("Selamat Datang di EatEase!")
                .font(.title)
                .padding()

            if let email = authManager.userSession?.email {
                Text("Anda login sebagai: \(email)")
                    .font(.headline)
                    .padding(.bottom)
            }

            Button(action: {
                authManager.signOut()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Untuk preview, kita bisa inject dummy AuthenticationManager
        // dan set user session secara manual jika perlu
        let manager = AuthenticationManager()
        // Jika ingin preview tampilan logged-in:
        // manager.userSession = ... (perlu mock FirebaseAuth.User, agak rumit untuk preview)
        // Jadi lebih mudah test di simulator/device
        ContentView().environmentObject(manager)
    }
}
