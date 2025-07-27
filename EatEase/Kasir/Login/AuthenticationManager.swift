import Foundation
import FirebaseAuth

class AuthenticationManager: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            if let user = user {
                print("User is signed in with uid: \(user.uid)")
            } else {
                print("User is signed out.")
            }
        }
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
//
//    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                completion(error)
//                return
//            }
//            completion(nil)
//        }
//    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
