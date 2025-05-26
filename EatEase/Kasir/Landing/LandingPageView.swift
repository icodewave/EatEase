//
//  LandingPageView.swift
//  EatEase
//
//  Created by iCodeWave Community on 26/05/25.
//


// EatEase/Kasir/Landing/LandingPageView.swift
import SwiftUI

struct LandingPageView: View {
    @StateObject private var viewModel = LandingPageViewModel()
    @State private var showingItemDetail: MenuItem? = nil
    @EnvironmentObject var authManager: AuthenticationManager
// Untuk navigasi ke detail item

    var body: some View {
        NavigationStack { // Gunakan NavigationStack untuk iOS 16+ atau NavigationView untuk versi sebelumnya
            VStack(spacing: 0) {
                // Search Bar
                TextField("Search", text: $viewModel.searchText)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(viewModel.selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                // Item List
                if viewModel.isLoading {
                    ProgressView("Memuat item...")
                        .frame(maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else if viewModel.filteredMenuItems.isEmpty && !viewModel.searchText.isEmpty {
                    Text("Tidak ada item ditemukan untuk \"\(viewModel.searchText)\".")
                        .padding()
                        .frame(maxHeight: .infinity)
                } else if viewModel.filteredMenuItems.isEmpty && viewModel.selectedCategory != "All item" {
                     Text("Tidak ada item dalam kategori \"\(viewModel.selectedCategory)\".")
                        .padding()
                        .frame(maxHeight: .infinity)
                }
                else {
                    List {
                        ForEach(viewModel.filteredMenuItems) { item in
                            Button(action: {
                                self.showingItemDetail = item // Atur item untuk navigasi
                            }) {
                                MenuItemRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle()) // Agar seluruh row bisa diklik tanpa style default button
                        }
                    }
                    .listStyle(PlainListStyle()) // Menghilangkan style default List
                }
                
                // Bottom Bar (placeholder, Anda bisa kembangkan ini)
                HStack {
                    Button(action: {
                        // Aksi untuk tombol tambah (misalnya: tambah pelanggan baru, atau menu custom)
                        print("Tombol Tambah diklik")
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    
                    Button(action: {
                        // Aksi untuk tombol Charge (misalnya: ke halaman pembayaran)
                        print("Tombol Charge diklik")
                    }) {
                        Text("Charge RP 0") // Nanti bisa dinamis
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Aksi untuk tombol keranjang (misalnya: tampilkan keranjang)
                        print("Tombol Keranjang diklik")
                    }) {
                        Image(systemName: "cart.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(7) // Padding agar area klik lebih besar
                    }
                }
                .padding()
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.bottom))

            }
            .navigationTitle("EatEase!")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Aksi untuk menu hamburger
                        print("Menu diklik")
                    }) {
                        Image(systemName: "line.horizontal.3")
                    }
                }
                ToolbarItem(placement: .principal) {
                    if let email = authManager.userSession?.email {
                        Text("Welcome! \(email)")
                            .font(.headline)
                            .padding(.bottom)
                    }
                   }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            // Navigasi ke detail item
            .sheet(item: $showingItemDetail) { item in
                // Ganti ItemDetailView dengan view detail yang Anda buat
                // ItemDetailView ini akan mirip dengan gambar kanan yang Anda berikan
                ItemDetailView(item: item, viewModel: viewModel)
            }
            .onAppear {
                // Jika Anda ingin data di-refresh setiap kali halaman muncul
                // viewModel.fetchMenuItems() 
                // Namun, data sudah di-fetch saat init ViewModel
            }
        }
    }
}

// Subview untuk setiap baris item
struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack {
            // Placeholder untuk gambar. Ganti dengan AsyncImage jika Anda punya URL gambar
            Image(systemName: "photo.on.rectangle.angled") // Placeholder
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .padding(.trailing, 8)

            VStack(alignment: .leading) {
                Text(item.nama)
                    .font(.headline)
                Text("Rp \(Int(item.harga))") // Format harga sederhana
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(item.desc)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.gray)

                // Teks "Stock 50" ada di gambar, tapi tidak di struktur DB.
                // Jika ingin, Anda bisa hardcode atau tambahkan ke DB.
                // Text("Stock 50")
                //    .font(.caption)
                //    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


// Placeholder untuk ItemDetailView (gambar kanan)
struct ItemDetailView: View {
    let item: MenuItem
    @ObservedObject var viewModel: LandingPageViewModel // Untuk memanggil addToCart
    
    // State lokal untuk detail item
    @State private var selectedVariant: String = "Biasa" // Contoh variant
    @State private var quantity: Int = 1
    @State private var notes: String = ""
    @State private var applyDiscount5: Bool = false
    @State private var applyDiscount100: Bool = false

    // Contoh data variant dan harga (Anda mungkin perlu mengambil ini dari Firestore atau struktur lain)
    let variants: [String: Double] = [
        "Biasa": 21600, // Harga ini mungkin perlu disesuaikan dari item.harga atau data terpisah
        "Sedang": 22000,
        "Pedas": 23000
    ]
    
    @Environment(\.dismiss) var dismiss // Untuk menutup sheet

    var body: some View {
        NavigationView { // Atau NavigationStack jika ini root dari navigasi baru
            VStack(alignment: .leading, spacing: 16) {
                Text("VARIANT")
                    .font(.headline)
                    .padding(.top)

                ForEach(variants.keys.sorted(), id: \.self) { variantKey in
                    Button(action: {
                        selectedVariant = variantKey
                    }) {
                        HStack {
                            Text(variantKey)
                            Spacer()
                            Text("\(Int(variants[variantKey] ?? item.harga))") // Gunakan harga variant atau harga item default
                        }
                        .padding()
                        .background(selectedVariant == variantKey ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                        .foregroundColor(selectedVariant == variantKey ? .white : .primary)
                        .cornerRadius(8)
                    }
                }

                Text("QUANTITY")
                    .font(.headline)
                HStack {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    Spacer()
                    Text("\(quantity)")
                        .font(.title2)
                    Spacer()
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                Text("DISCOUNT")
                    .font(.headline)
                Toggle(isOn: $applyDiscount5) {
                    Text("Disc (5%)")
                }
                Toggle(isOn: $applyDiscount100) {
                    Text("Gratis (100%)")
                }

                Text("Notes..")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Spacer()
                
                Button(action: {
                    // Tentukan diskon yang diterapkan
                    var discountValue: Double? = nil
                    if applyDiscount100 {
                        discountValue = 1.0 // 100%
                    } else if applyDiscount5 {
                        discountValue = 0.05 // 5%
                    }
                    
                    viewModel.addToCart(item: item, variant: selectedVariant, quantity: quantity, discount: discountValue)
                    dismiss() // Tutup sheet setelah menambahkan
                }) {
                    Text("ADD TO CART") // Atau sesuaikan teksnya
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle(item.nama)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("ADD") { // Ini adalah tombol ADD seperti di gambar kanan atas
                         // Tentukan diskon yang diterapkan
                        var discountValue: Double? = nil
                        if applyDiscount100 {
                            discountValue = 1.0 // 100%
                        } else if applyDiscount5 {
                            discountValue = 0.05 // 5%
                        }
                        viewModel.addToCart(item: item, variant: selectedVariant, quantity: quantity, discount: discountValue)
                        dismiss()
                    }
                }
            }
        }
    }
}


struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
