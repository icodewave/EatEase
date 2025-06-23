//import SwiftUI
//
//struct LoginView: View {
//    @StateObject var viewModel: LoginViewModel
//
//    init(authManager: AuthenticationManager) {
//        _viewModel = StateObject(wrappedValue: LoginViewModel(authManager: authManager))
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("EatEase Login")
//                .font(.largeTitle)
//                .fontWeight(.bold)	
//                .padding(.bottom, 30)
//
//            TextField("Email", text: $viewModel.email)
//                .keyboardType(.emailAddress)
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(8)
//
//            SecureField("Password", text: $viewModel.password)
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(8)
//
//            if let errorMessage = viewModel.errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .font(.caption)
//                    .padding(.top, 5)
//                    .multilineTextAlignment(.center)
//            }
//
//            if viewModel.isLoading {
//                ProgressView()
//                    .padding(.top, 20)
//            } else {
//                Button(action: {
//                    viewModel.login()
//                }) {
//                    Text("Login")
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .padding(.top, 20)
//            }
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView(authManager: AuthenticationManager())
//    }
//}



import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    init(authManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authManager: authManager))
    }
    
    var body: some View {
        ZStack {
            // Background dengan warna gradasi atau solid seperti di referensi
            // Anda bisa menyesuaikannya dengan warna yang lebih spesifik jika diinginkan
            //            LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            //                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: [
                Color.blue,
                Color.white
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer() // Mendorong konten ke tengah atau sedikit ke atas
                
                // "Hello. Welcome back!" text inspired by the reference
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Welcome back!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 60) // Memberi jarak antara teks sambutan dan input fields
                
                VStack(spacing: 20) {
                    // Email Input Field
                    TextField("enter your account", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white.opacity(0.9)) // Latar belakang putih transparan
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Shadow untuk sedikit kedalaman
                    
                    // Password Input Field
                    SecureField("Enter your password...", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Forgot Password (Opsional, dari referensi)
                    HStack {
                        Spacer()
                        Button(action: {
                            // Aksi untuk "Forgot the password?"
                            print("Forgot password tapped")
                        }) {
                            Text("Forgot the password?")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.footnote)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Login Button
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 20)
                    } else {
                        Button(action: {
                            viewModel.login()
                        }) {
                            Text("Login")
                                .foregroundColor(Color.red.opacity(0.8)) // Warna teks disesuaikan dengan gradasi background
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white) // Latar belakang tombol putih
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal, 30) // Padding horizontal untuk konten utama
                
                // Spacer() di sini akan mendorong konten lebih ke tengah vertikal
                Spacer() // Ini penting agar konten tidak terlalu ke atas jika bagian sign up dihapus
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authManager: AuthenticationManager())
    }
}

