// EatEase/Kasir/Landing/LandingPageViewModel.swift
import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth // Untuk Auth

@MainActor
class LandingPageViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var filteredMenuItems: [MenuItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All item"
    @Published var categories: [String] = ["All item"]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Properti untuk Cart
    @Published var currentCart: Cart?
    @Published var isCartLoading: Bool = false
    @Published var cartErrorMessage: String? = nil
    @Published var totalCharge: Double = 0.0
    @Published var totalCartItemsQuantity: Int = 0


    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var cartListener: ListenerRegistration? // Untuk real-time update cart

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchMenuItems()

        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, selectedCategory) in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $currentCart
            .map { $0?.totalAmount ?? 0.0 }
            .assign(to: &$totalCharge)
        
        $currentCart
            .map { $0?.totalItemsQuantity ?? 0 }
            .assign(to: &$totalCartItemsQuantity)

        if let userId = currentUserId {
            fetchOrCreateCart(for: userId)
        }
    }
    
    deinit {
        cartListener?.remove()
    }

    func fetchMenuItems() {
        isLoading = true
        errorMessage = nil
        db.collection("menu_makanan").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = "Gagal mengambil data menu: \(error.localizedDescription)"
                return
            }

            guard let documents = querySnapshot?.documents else {
                self.errorMessage = "Tidak ada data menu ditemukan."
                return
            }

            let items = documents.compactMap { try? $0.data(as: MenuItem.self) }
            
            self.menuItems = items
            self.extractCategories()
            self.applyFilters()
        }
    }

    private func extractCategories() {
        let uniqueCategories = Set(menuItems.map { $0.kategori })
        self.categories = ["All item"] + Array(uniqueCategories).sorted()
        if !self.categories.contains(self.selectedCategory) {
            self.selectedCategory = "All item"
        }
    }

    private func applyFilters() {
        var itemsToFilter = menuItems

        if selectedCategory != "All item" {
            itemsToFilter = itemsToFilter.filter { $0.kategori == selectedCategory }
        }

        if !searchText.isEmpty {
            itemsToFilter = itemsToFilter.filter {
                $0.nama.localizedCaseInsensitiveContains(searchText) ||
                $0.desc.localizedCaseInsensitiveContains(searchText)
            }
        }
        self.filteredMenuItems = itemsToFilter
    }

    // MARK: - Cart Logic
    
    // EatEase/Kasir/Landing/LandingPageViewModel.swift
    // ... (kode yang sudah ada) ...

    // Tambahkan di dalam class LandingPageViewModel

    // MARK: - Order Logic
    func placeOrder(
        userId: String,
        cart: Cart,
        namaPelanggan: String,
        nomorMeja: String,
        metodePembayaran: String,
        status: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !cart.items.isEmpty else {
            completion(.failure(NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keranjang kosong."])))
            return
        }

        // 1. Ubah CartItems menjadi OrderItems
        let orderItems = cart.items.map { cartItem -> OrderItem in
            OrderItem(
                id: cartItem.id, // ID item yang sama
                menuMakananId: cartItem.menuMakananId,
                nama: cartItem.nama,
                harga: cartItem.harga, // Harga saat itu
                kuantitas: cartItem.kuantitas,
                variant: cartItem.variant,
                notes: cartItem.notes
            )
        }

        // 2. Buat objek Order baru
        let newOrder = Order(
            userId: userId,
            items: orderItems,
            createdAt: Timestamp(date: Date()),
            updatedAt: Timestamp(date: Date()),
            namaPelanggan: namaPelanggan,
            nomorMeja: nomorMeja,
            metodePembayaran: metodePembayaran,
            status: status,
            totalAmount: cart.totalAmount // Ambil total dari keranjang
        )

        // 3. Simpan order ke Firestore
        do {
            // Buat referensi dokumen terlebih dahulu
            let newOrderRef = db.collection("orders").document()
            let orderId = newOrderRef.documentID
            
            // Set data dengan ID yang sudah ditentukan
            try newOrderRef.setData(from: newOrder) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    // 4. Jika berhasil, bersihkan keranjang saat ini
                    
                    if var currentCartToClear = self.currentCart, let cartDocId = currentCartToClear.id {
                        currentCartToClear.items = [] // Kosongkan item
                        currentCartToClear.updatedAt = Timestamp(date: Date()) // Update timestamp
                        
                        do {
                            try self.db.collection("carts").document(cartDocId).setData(from: currentCartToClear, merge: true) { error in
                                if let error = error {
                                    print("Peringatan: Pesanan berhasil, tapi gagal membersihkan keranjang: \(error.localizedDescription)")
                                    // Pesanan tetap berhasil, tapi keranjang tidak bersih
                                } else {
                                    print("Keranjang berhasil dibersihkan setelah pesanan.")
                                    // Listener pada keranjang akan otomatis mengupdate UI
                                }
                                // Kirim success untuk order terlepas dari pembersihan keranjang (prioritas order)
                                completion(.success(orderId))
                            }
                        } catch {
                            print("Peringatan: Pesanan berhasil, tapi error saat menyiapkan pembersihan keranjang: \(error.localizedDescription)")
                            completion(.success(orderId))
                        }
                    } else {
                        // Jika tidak ada currentCart (seharusnya tidak terjadi di alur ini)
                        completion(.success(orderId))
                    }
                }
            }
            
            print("Sedang membuat order dengan ID: \(orderId)")
            
        } catch {
            completion(.failure(error))
        }
    }
    // ... (sisa kode LandingPageViewModel) ...

    func userLoggedIn(userId: String) {
        if self.currentCart?.userId != userId || self.currentCart == nil {
             fetchOrCreateCart(for: userId)
        }
    }

    func userLoggedOut() {
        cartListener?.remove()
        cartListener = nil
        currentCart = nil
        cartErrorMessage = nil
        totalCharge = 0.0
        totalCartItemsQuantity = 0
    }

    func fetchOrCreateCart(for userId: String) {
        guard !userId.isEmpty else {
            self.cartErrorMessage = "User ID tidak valid."
            return
        }

        isCartLoading = true
        cartErrorMessage = nil
        
        cartListener?.remove()

        let cartRef = db.collection("carts").whereField("userId", isEqualTo: userId)
                        .limit(to: 1)

        cartListener = cartRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            self.isCartLoading = false

            if let error = error {
                self.cartErrorMessage = "Gagal mengambil keranjang: \(error.localizedDescription)"
                print("Error fetching cart: \(error)")
                return
            }

            if let document = querySnapshot?.documents.first {
                do {
                    self.currentCart = try document.data(as: Cart.self)
                    self.cartErrorMessage = nil
                } catch {
                    self.cartErrorMessage = "Gagal memproses data keranjang: \(error.localizedDescription)"
                    print("Error decoding cart: \(error)")
                    self.createNewCart(for: userId)
                }
            } else {
                self.createNewCart(for: userId)
            }
        }
    }

    private func createNewCart(for userId: String) {
        guard !userId.isEmpty else { return }
        
        let newCartObject = Cart(
            userId: userId,
            items: [],
            createdAt: Timestamp(date: Date()),
            updatedAt: Timestamp(date: Date())
        )

        do {
            // Buat referensi dokumen terlebih dahulu
            let newDocumentRef = db.collection("carts").document()
            
            // Set data dengan ID yang sudah ditentukan
            try newDocumentRef.setData(from: newCartObject) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.cartErrorMessage = "Gagal membuat keranjang baru di server: \(error.localizedDescription)"
                    print("Error creating new cart (server-side): \(error)")
                } else {
                    print("Keranjang baru berhasil dibuat dengan ID: \(newDocumentRef.documentID)")
                    self.cartErrorMessage = nil
                    // Listener akan otomatis mendeteksi perubahan ini
                }
            }
            
            print("Sedang membuat keranjang dengan ID: \(newDocumentRef.documentID)")

        } catch {
            self.cartErrorMessage = "Gagal menyiapkan pembuatan keranjang baru (client-side): \(error.localizedDescription)"
            print("Error encoding new cart for creation (client-side): \(error)")
        }
    }


    func addToCart(menuItem: MenuItem, selectedVariantName: String, variantPrice: Double, quantity: Int, notes: String?, discount: Double?) {
        guard let userId = currentUserId else {
            cartErrorMessage = "Anda harus login untuk menambahkan item ke keranjang."
            print("User not logged in")
            return
        }

        guard var cart = currentCart, let cartDocumentId = cart.id else {
            cartErrorMessage = "Keranjang tidak ditemukan atau ID keranjang tidak valid. Mencoba mengambil/membuat..."
            print("Cart not found or cart ID nil for user: \(userId). Attempting to fetch/create.")
            fetchOrCreateCart(for: userId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                 self?.cartErrorMessage = "Keranjang sedang disiapkan. Silakan coba tambahkan item lagi."
            }
            return
        }
        
        let cartItemId = "\(menuItem.id ?? UUID().uuidString)_\(selectedVariantName)"

        if let index = cart.items.firstIndex(where: { $0.id == cartItemId }) {
            cart.items[index].kuantitas += quantity
            if let newNotes = notes, !newNotes.isEmpty {
                cart.items[index].notes = newNotes
            }
        } else {
            guard let menuItemId = menuItem.id else {
                cartErrorMessage = "ID item menu tidak valid."
                print("Menu item ID is nil, cannot add to cart.")
                return
            }
            let newCartItem = CartItem(
                id: cartItemId,
                menuMakananId: menuItemId,
                nama: menuItem.nama,
                harga: variantPrice,
                kuantitas: quantity,
                variant: selectedVariantName,
                notes: notes
            )
            cart.items.append(newCartItem)
        }

        cart.updatedAt = Timestamp(date: Date())
        
        do {
            try db.collection("carts").document(cartDocumentId).setData(from: cart, merge: true) { [weak self] error in
                if let error = error {
                    self?.cartErrorMessage = "Gagal mengupdate keranjang: \(error.localizedDescription)"
                    print("Error updating cart: \(error)")
                } else {
                    print("Keranjang berhasil diupdate.")
                    self?.cartErrorMessage = nil
                }
            }
        } catch {
            cartErrorMessage = "Gagal menyiapkan update keranjang: \(error.localizedDescription)"
            print("Error encoding cart for update: \(error)")
        }
    }
    
    func removeItemFromCart(cartItemId: String) {
        guard let userId = currentUserId, var cart = currentCart, let cartDocumentId = cart.id else {
            cartErrorMessage = "Tidak bisa menghapus item: data keranjang tidak lengkap."
            return
        }

        cart.items.removeAll { $0.id == cartItemId }
        cart.updatedAt = Timestamp(date: Date())

        do {
            try db.collection("carts").document(cartDocumentId).setData(from: cart, merge: true) { [weak self] error in
                 if let error = error {
                    self?.cartErrorMessage = "Gagal menghapus item dari keranjang: \(error.localizedDescription)"
                } else {
                    print("Item berhasil dihapus dari keranjang.")
                    self?.cartErrorMessage = nil
                }
            }
        } catch {
            cartErrorMessage = "Gagal menyiapkan penghapusan item: \(error.localizedDescription)"
        }
    }

    func updateItemQuantityInCart(cartItemId: String, newQuantity: Int) {
        guard let userId = currentUserId, var cart = currentCart, let cartDocumentId = cart.id else {
            cartErrorMessage = "Tidak bisa update kuantitas: data keranjang tidak lengkap."
            return
        }

        if let index = cart.items.firstIndex(where: { $0.id == cartItemId }) {
            if newQuantity > 0 {
                cart.items[index].kuantitas = newQuantity
            } else {
                cart.items.remove(at: index)
            }
            cart.updatedAt = Timestamp(date: Date())

            do {
                try db.collection("carts").document(cartDocumentId).setData(from: cart, merge: true) { [weak self] error in
                    if let error = error {
                        self?.cartErrorMessage = "Gagal update kuantitas item: \(error.localizedDescription)"
                    } else {
                        print("Kuantitas item berhasil diupdate.")
                        self?.cartErrorMessage = nil
                    }
                }
            } catch {
                cartErrorMessage = "Gagal menyiapkan update kuantitas: \(error.localizedDescription)"
            }
        }
    }
}
