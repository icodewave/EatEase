//
//  CheckoutView.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import SwiftUI
import FirebaseFirestore

struct CheckoutView: View {
    @ObservedObject var viewModel: LandingPageViewModel
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss

    @State private var namaPelanggan: String = ""
    @State private var nomorMeja: String = ""
    @State private var metodePembayaran: String = "Cash"
    @State private var isPlacingOrder: Bool = false
    @State private var orderError: String? = nil
    @State private var orderSuccess: Bool = false

    let paymentMethods = ["Cash", "Card", "Transfer", "QRIS"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detail Pelanggan")) {
                    TextField("Nama Pelanggan", text: $namaPelanggan)
                    TextField("Nomor Meja / Catatan (mis. Take Away)", text: $nomorMeja)
                }

                Section(header: Text("Metode Pembayaran")) {
                    Picker("Pilih Metode", selection: $metodePembayaran) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method)
                        }
                    }
                }

                // MODIFIKASI DI SINI: Bagian Ringkasan Pesanan
                Section(header: Text("Ringkasan Pesanan")) {
                    if let cart = viewModel.currentCart, !cart.items.isEmpty {
                        // Gunakan List untuk fungsionalitas onDelete
                        List {
                            ForEach(cart.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.nama)
                                            .font(.headline)
                                        Text("Qty: \(item.kuantitas) x Rp \(Int(item.harga))")
                                            .font(.caption)
                                        if let variant = item.variant, !variant.isEmpty {
                                            Text("Variant: \(variant)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        if let notes = item.notes, !notes.isEmpty {
                                            Text("Notes: \(notes)")
                                                .font(.caption)
                                                .italic()
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Text("Rp \(Int(item.harga * Double(item.kuantitas)))")
                                }
                            }
                            .onDelete(perform: deleteItems) // Tambahkan modifier onDelete

                            // Tampilkan total di luar ForEach, tapi masih di dalam List atau Section
                            HStack {
                                Text("Total").bold()
                                Spacer()
                                Text("Rp \(Int(cart.totalAmount))").bold()
                            }
                        }
                    } else {
                        Text("Keranjang kosong.")
                    }
                }
                // SELESAI MODIFIKASI

                if let error = orderError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
                
                if orderSuccess {
                    Text("Pesanan berhasil dibuat!")
                        .foregroundColor(.green)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                }

                Button(action: placeOrderAction) {
                    if isPlacingOrder {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Buat Pesanan & Bayar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isPlacingOrder || viewModel.currentCart?.items.isEmpty ?? true || namaPelanggan.isEmpty || nomorMeja.isEmpty || orderSuccess)
            }
            .navigationTitle("Checkout")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                // Opsional: Tambahkan tombol Edit Mode jika ingin UI swipe yang lebih jelas
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     EditButton()
                // }
            }
        }
    }

    // Fungsi untuk menghapus item dari List
    private func deleteItems(at offsets: IndexSet) {
        guard let cart = viewModel.currentCart else { return }
        
        // Dapatkan ID item yang akan dihapus berdasarkan offsets
        let itemsToDelete = offsets.map { cart.items[$0] }
        
        for item in itemsToDelete {
            viewModel.removeItemFromCart(cartItemId: item.id)
        }
        
        // Jika setelah penghapusan keranjang menjadi kosong dan nama pelanggan/meja sudah terisi,
        // mungkin user ingin membatalkan, atau kita biarkan saja tombol "Buat Pesanan" menjadi disabled.
        // UI akan update otomatis.
    }

    func placeOrderAction() {
        guard let userId = authManager.userSession?.uid, let cart = viewModel.currentCart, !cart.items.isEmpty else {
            orderError = "User tidak login atau keranjang kosong."
            return
        }

        isPlacingOrder = true
        orderError = nil
        orderSuccess = false

        viewModel.placeOrder(
            userId: userId,
            cart: cart,
            namaPelanggan: namaPelanggan,
            nomorMeja: nomorMeja,
            metodePembayaran: metodePembayaran,
            status: "pending"
        ) { result in
            isPlacingOrder = false
            switch result {
            case .success(let orderId):
                print("Pesanan berhasil dibuat dengan ID: \(orderId)")
                orderSuccess = true
                // ViewModel akan menghandle pembersihan keranjang
            case .failure(let error):
                orderError = error.localizedDescription
                print("Gagal membuat pesanan: \(error.localizedDescription)")
            }
        }
    }
}


// Preview (opsional)
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        // Anda perlu mock ViewModel dan AuthManager di sini
        let mockViewModel = LandingPageViewModel()
        // Isi mockViewModel.currentCart dengan beberapa data untuk preview
        let mockItem = CartItem(id: "1", menuMakananId: "menu1", nama: "Nasi Goreng", harga: 20000, kuantitas: 1, variant: "Biasa", notes: nil)
        mockViewModel.currentCart = Cart(userId: "mockUser", items: [mockItem], createdAt: Timestamp(), updatedAt: Timestamp())
        
        let mockAuthManager = AuthenticationManager()
        // mockAuthManager.userSession = ... // (jika diperlukan untuk preview)

        return CheckoutView(viewModel: mockViewModel)
            .environmentObject(mockAuthManager)
    }
}
