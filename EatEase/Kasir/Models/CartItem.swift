//
//  CartItem.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import Foundation
import FirebaseFirestore // Untuk Timestamp

struct CartItem: Identifiable, Codable, Hashable {
    var id: String // ID unik untuk item dalam keranjang, bisa UUID().uuidString atau menuMakananId + variant
    var menuMakananId: String
    var nama: String
    var harga: Double // Harga per unit (bisa harga variant)
    var kuantitas: Int
    var variant: String? // Opsional, jika ada variant yang dipilih
    var notes: String? // Opsional, catatan dari pengguna
    // `discountApplied` bisa ditambahkan di sini jika diskon per item
    // `createdAt` dan `updatedAt` untuk CartItem tidak ada di struktur Anda, jadi kita abaikan

    // Conformance to Hashable (jika diperlukan, misalnya untuk diffing)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}