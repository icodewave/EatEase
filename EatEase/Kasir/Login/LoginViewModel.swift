import Foundation
import Combine // Untuk ObservableObject dan Published

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var authManager: AuthenticationManager

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    func login() {
        isLoading = true
        errorMessage = nil
        authManager.signIn(email: email, password: password) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
                // Jika sukses, RootView akan otomatis mengarahkan ke ContentView
            }
        }
    }

//    func signUp() {
//        isLoading = true
//        errorMessage = nil
//        authManager.signUp(email: email, password: password) { [weak self] error in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                }
//                // Jika sukses, RootView akan otomatis mengarahkan ke ContentView
//            }
//        }
//    }
}
