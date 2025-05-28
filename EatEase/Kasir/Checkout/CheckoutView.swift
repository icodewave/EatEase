//
//  CheckoutView.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import SwiftUI
import FirebaseFirestore // Untuk Timestamp

struct CheckoutView: View {
    @ObservedObject var viewModel: LandingPageViewModel // Akses ke currentCart dan fungsi placeOrder
    @EnvironmentObject var authManager: AuthenticationManager // Untuk userId
    @Environment(\.dismiss) var dismiss

    @State private var namaPelanggan: String = ""
    @State private var nomorMeja: String = ""
    @State private var metodePembayaran: String = "Cash" // Default
    @State private var isPlacingOrder: Bool = false
    @State private var orderError: String? = nil
    @State private var orderSuccess: Bool = false

    let paymentMethods = ["Cash", "Card", "Transfer", "QRIS"] // Contoh metode

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

                Section(header: Text("Ringkasan Pesanan")) {
                    if let cart = viewModel.currentCart {
                        ForEach(cart.items) { item in
                            HStack {
                                Text("\(item.nama) (\(item.kuantitas)x)")
                                Spacer()
                                Text("Rp \(Int(item.harga * Double(item.kuantitas)))")
                            }
                        }
                        HStack {
                            Text("Total").bold()
                            Spacer()
                            Text("Rp \(Int(cart.totalAmount))").bold()
                        }
                    } else {
                        Text("Keranjang kosong.")
                    }
                }

                if let error = orderError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
                
                if orderSuccess {
                    Text("Pesanan berhasil dibuat!")
                        .foregroundColor(.green)
                        .onAppear {
                            // Auto dismiss setelah beberapa detik
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
            }
        }
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
            status: "pending" // Atau status awal lainnya, misal "diproses"
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