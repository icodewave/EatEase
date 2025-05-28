// EatEase/Kasir/Landing/LandingPageView.swift
import SwiftUI

struct LandingPageView: View {
    @StateObject private var viewModel = LandingPageViewModel()
    @State private var showingItemDetail: MenuItem? = nil
    @State private var showingCheckoutView: Bool = false // State baru
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ... (Search Bar, Category Filters, Item List tetap sama) ...
                TextField("Search", text: $viewModel.searchText)
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)

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

                if viewModel.isLoading {
                    ProgressView("Memuat item...")
                        .frame(maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else if viewModel.filteredMenuItems.isEmpty {
                     Text(viewModel.searchText.isEmpty ? "Tidak ada item dalam kategori \"\(viewModel.selectedCategory)\"." : "Tidak ada item ditemukan untuk \"\(viewModel.searchText)\".")
                        .padding()
                        .frame(maxHeight: .infinity)
                }
                else {
                    List {
                        ForEach(viewModel.filteredMenuItems) { item in
                            Button(action: {
                                self.showingItemDetail = item
                            }) {
                                MenuItemRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                if let cartError = viewModel.cartErrorMessage, !cartError.isEmpty {
                    Text("Cart Error: \(cartError)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                }


                // Bottom Bar
                HStack {
                    Button(action: {
                        print("Tombol Tambah diklik")
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    
                    Button(action: {
                        // Aksi untuk tombol Charge: tampilkan CheckoutView
                        if viewModel.currentCart?.items.isEmpty ?? true {
                            // Bisa tampilkan alert bahwa keranjang kosong
                            print("Keranjang kosong, tidak bisa checkout.")
                        } else {
                            showingCheckoutView = true
                        }
                    }) {
                        Text("Charge Rp \(Int(viewModel.totalCharge))")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.totalCartItemsQuantity > 0 ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.totalCartItemsQuantity == 0) // Disable jika tidak ada item
                    .padding(.horizontal)
                    
                    Button(action: {
                        print("Tombol Keranjang diklik")
                        // Anda bisa buat view khusus untuk melihat/mengedit keranjang
                        // Untuk saat ini, bisa jadi tidak ada aksi atau tampilkan summary singkat
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            if viewModel.totalCartItemsQuantity > 0 {
                                Text("\(viewModel.totalCartItemsQuantity)")
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                        .padding(7)
                    }
                }
                .padding()
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.bottom))

            }
            .navigationTitle("Point of Sale")
            // ... (toolbar tetap sama) ...
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { print("Menu diklik") }) {
                        Image(systemName: "line.horizontal.3")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { print("Edit diklik") }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(item: $showingItemDetail) { item in
                ItemDetailView(item: item, viewModel: viewModel)
            }
            // Sheet baru untuk CheckoutView
            .sheet(isPresented: $showingCheckoutView) {
                // Pastikan viewModel dan authManager di-pass dengan benar
                CheckoutView(viewModel: viewModel)
                    .environmentObject(authManager) // CheckoutView butuh authManager
            }
            .onAppear {
                if let userId = authManager.userSession?.uid {
                    viewModel.userLoggedIn(userId: userId)
                } else {
                    viewModel.userLoggedOut()
                }
            }
            .onChange(of: authManager.userSession) { newUserSession in
                if let userId = newUserSession?.uid {
                    viewModel.userLoggedIn(userId: userId)
                } else {
                    viewModel.userLoggedOut()
                }
            }
        }
    }
}

// ... (Preview untuk LandingPageView tetap sama) ...

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        // Buat mock authManager untuk preview
        let mockAuthManager = AuthenticationManager()
        // Jika ingin preview dengan user login:
        // mockAuthManager.userSession = // Anda perlu mock FirebaseAuth.User di sini, yang agak rumit
        
        LandingPageView()
            .environmentObject(mockAuthManager) // Sediakan authManager untuk preview
    }
}
