//
//  LandingPageViewModel.swift
//  EatEase
//
//  Created by iCodeWave Community on 26/05/25.
//


// EatEase/Kasir/Landing/LandingPageViewModel.swift
import Foundation
import FirebaseFirestore
import Combine // Untuk @Published dan ObservableObject

@MainActor // Pastikan update UI terjadi di main thread
class LandingPageViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var filteredMenuItems: [MenuItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All item" // Kategori default
    @Published var categories: [String] = ["All item"] // Daftar kategori dinamis
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchMenuItems()

        // Kombinasikan publisher untuk searchText dan selectedCategory
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Tunda sedikit untuk performa
            .sink { [weak self] (searchText, selectedCategory) in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }

    func fetchMenuItems() {
        isLoading = true
        errorMessage = nil
        db.collection("menu_makanan").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = "Gagal mengambil data: \(error.localizedDescription)"
                print("Error getting documents: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                self.errorMessage = "Tidak ada data ditemukan."
                print("No documents")
                return
            }

            let items = documents.compactMap { document -> MenuItem? in
                try? document.data(as: MenuItem.self)
            }
            
            self.menuItems = items
            self.extractCategories()
            self.applyFilters() // Terapkan filter awal
        }
    }

    private func extractCategories() {
        let uniqueCategories = Set(menuItems.map { $0.kategori })
        // Urutkan kategori agar konsisten, dan tambahkan "All item" di depan
        self.categories = ["All item"] + Array(uniqueCategories).sorted()
        if !self.categories.contains(self.selectedCategory) { // Jika kategori terpilih sebelumnya tidak ada lagi
            self.selectedCategory = "All item"
        }
    }

    private func applyFilters() {
        var itemsToFilter = menuItems

        // Filter berdasarkan kategori
        if selectedCategory != "All item" {
            itemsToFilter = itemsToFilter.filter { $0.kategori == selectedCategory }
        }

        // Filter berdasarkan teks pencarian
        if !searchText.isEmpty {
            itemsToFilter = itemsToFilter.filter {
                $0.nama.localizedCaseInsensitiveContains(searchText) ||
                $0.desc.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        self.filteredMenuItems = itemsToFilter
    }
    
    // Fungsi ini bisa Anda kembangkan untuk logika keranjang belanja
    func addToCart(item: MenuItem, variant: String, quantity: Int, discount: Double?) {
        print("Menambahkan \(item.nama) (\(variant)) - \(quantity) pcs ke keranjang.")
        // Logika penambahan ke keranjang akan ada di sini
    }
}
