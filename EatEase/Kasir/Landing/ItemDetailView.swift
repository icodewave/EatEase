//
//  ItemDetailView.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import SwiftUI

struct ItemDetailView: View {
    let menuItem: MenuItem // Ganti nama variabel agar lebih jelas
    @ObservedObject var viewModel: LandingPageViewModel
    
    @State private var selectedVariantName: String
    @State private var currentVariantPrice: Double
    @State private var quantity: Int = 1
    @State private var notes: String = ""
    // Diskon sementara dihilangkan dari sini, bisa ditangani di halaman checkout atau jika ada aturan diskon otomatis
    // @State private var applyDiscount5: Bool = false
    // @State private var applyDiscount100: Bool = false

    // Contoh data variant (IDEALNYA INI DATANG DARI `menuItem` ATAU FIREBASE)
    // Untuk sekarang, kita buat asumsi berdasarkan nama item
    var variants: [String: Double] {
        // Ini contoh sederhana, Anda perlu logika yang lebih baik
        // atau struktur data variant di MenuItem Anda.
        if menuItem.nama.lowercased().contains("nasi goreng") {
            return [
                "Biasa": menuItem.harga, // Harga dasar dari item
                "Sedang": menuItem.harga + 1000, // Contoh penyesuaian harga
                "Pedas": menuItem.harga + 2000
            ]
        }
        return ["Original": menuItem.harga] // Default jika tidak ada variant spesifik
    }
    
    @Environment(\.dismiss) var dismiss

    init(item: MenuItem, viewModel: LandingPageViewModel) {
        self.menuItem = item
        self.viewModel = viewModel
        // Inisialisasi state variant awal
        let defaultVariantName = item.nama.lowercased().contains("nasi goreng") ? "Biasa" : "Original"
        self._selectedVariantName = State(initialValue: defaultVariantName)
        self._currentVariantPrice = State(initialValue: (item.nama.lowercased().contains("nasi goreng") ? item.harga : item.harga)) // Harga awal
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(menuItem.desc)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("VARIANT")
                    .font(.headline)
                    .padding(.top)
                
                // Variant Picker
                Picker("Variant", selection: $selectedVariantName) {
                    ForEach(variants.keys.sorted(), id: \.self) { variantKey in
                        Text(variantKey).tag(variantKey)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Atau style lain yang Anda suka
                .onChange(of: selectedVariantName) { newVariant in
                    currentVariantPrice = variants[newVariant] ?? menuItem.harga
                }
                
                Text("Harga Variant: Rp \(Int(currentVariantPrice))")
                    .font(.subheadline)
                    .padding(.bottom)


                Text("QUANTITY")
                    .font(.headline)
                HStack {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Image(systemName: "minus.circle.fill").font(.title2)
                    }
                    Spacer()
                    Text("\(quantity)").font(.title2)
                    Spacer()
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                Text("Notes..")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Spacer()
                
                if let cartError = viewModel.cartErrorMessage {
                    Text(cartError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }

                Button(action: {
                    viewModel.addToCart(
                        menuItem: menuItem,
                        selectedVariantName: selectedVariantName,
                        variantPrice: currentVariantPrice, // Kirim harga variant yang terpilih
                        quantity: quantity,
                        notes: notes.isEmpty ? nil : notes,
                        discount: nil // Diskon sementara null
                    )
                    // Hanya dismiss jika tidak ada error atau berdasarkan logika tertentu
                    if viewModel.cartErrorMessage == nil {
                         dismiss()
                    }
                }) {
                    Text("ADD TO CART")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle(menuItem.nama)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("ADD") { // Tombol "ADD" di kanan atas juga melakukan aksi yang sama
                        viewModel.addToCart(
                            menuItem: menuItem,
                            selectedVariantName: selectedVariantName,
                            variantPrice: currentVariantPrice,
                            quantity: quantity,
                            notes: notes.isEmpty ? nil : notes,
                            discount: nil
                        )
                        if viewModel.cartErrorMessage == nil {
                             dismiss()
                        }
                    }
                }
            }
            .onAppear {
                 // Set harga variant awal dengan benar saat view muncul
                currentVariantPrice = variants[selectedVariantName] ?? menuItem.harga
            }
        }
    }
}
