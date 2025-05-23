import SwiftUI
import FirebaseCore // Import FirebaseCore

// AppDelegate untuk konfigurasi Firebase jika menggunakan UIKit lifecycle (opsional untuk SwiftUI murni)
// class AppDelegate: NSObject, UIApplicationDelegate {
//   func application(_ application: UIApplication,
//                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//     FirebaseApp.configure()
//     return true
//   }
// }

@main
struct EatEaseApp: App {
    // Jika menggunakan AppDelegate:
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Inisialisasi Firebase langsung di init() untuk SwiftUI App lifecycle
    init() {
        FirebaseApp.configure()
        print("Firebase configured!") // Tambahkan ini untuk debugging
    }

    var body: some Scene {
        WindowGroup {
            RootView() // RootView akan mengelola alur login
        }
    }
}
