// EatEase/Kasir/Landing/LandingPageView.swift
import SwiftUI

struct LandingPageView: View {
    @StateObject private var viewModel = LandingPageViewModel()
    @State private var showingItemDetail: MenuItem? = nil
    @State private var showingCheckoutView: Bool = false
    @State private var showingSidebar: Bool = false // State untuk sidebar
    @EnvironmentObject var authManager: AuthenticationManager

    // Lebar sidebar
    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width * 0.75 // 75% lebar layar

    var body: some View {
        // ZStack utama untuk sidebar dan konten
        ZStack {
            // Konten Utama (NavigationStack Anda)
            NavigationStack {
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
                            if viewModel.currentCart?.items.isEmpty ?? true {
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
                        .disabled(viewModel.totalCartItemsQuantity == 0)
                        .padding(.horizontal)
                        
                        Button(action: {
                            print("Tombol Keranjang diklik")
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
                .navigationTitle("EatEase")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation { // Animasi untuk sidebar
                                showingSidebar.toggle()
                            }
                        }) {
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
                .sheet(isPresented: $showingCheckoutView) {
                    CheckoutView(viewModel: viewModel)
                        .environmentObject(authManager)
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
                        showingSidebar = false // Tutup sidebar jika user logout
                    }
                }
                // Nonaktifkan interaksi konten utama saat sidebar terbuka
                .disabled(showingSidebar)

            } // Akhir NavigationStack
            .offset(x: showingSidebar ? sidebarWidth : 0) // Geser konten utama saat sidebar muncul
            .animation(.easeInOut, value: showingSidebar) // Animasi untuk geser konten

            // Dimmer (Overlay Gelap)
            if showingSidebar {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showingSidebar = false
                        }
                    }
                    .transition(.opacity) // Transisi untuk dimmer
            }

            // Sidebar View
            if showingSidebar {
                SidebarView(isShowing: $showingSidebar)
                    .environmentObject(authManager)
                    .frame(width: sidebarWidth)
                    .offset(x: -((UIScreen.main.bounds.width - sidebarWidth) / 2)) // Pusatkan sidebar saat muncul
                    .transition(.move(edge: .leading)) // Transisi slide-in dari kiri
                    .zIndex(1) // Pastikan sidebar di atas konten lain
            }
        } // Akhir ZStack Utama
    }
}

// ... Preview untuk LandingPageView tetap sama ...
struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthManager = AuthenticationManager()
        LandingPageView()
            .environmentObject(mockAuthManager)
    }
}
