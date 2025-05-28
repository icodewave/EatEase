//
//  OrderItem.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import Foundation

struct OrderItem: Identifiable, Codable, Hashable {
    var id: String // ID unik untuk item dalam order (misalnya, menuMakananId + variant)
    var menuMakananId: String
    var nama: String
    var harga: Double // Harga per unit pada saat order
    var kuantitas: Int
    var variant: String? // Opsional, jika ada variant
    var notes: String?   // Opsional, catatan dari pengguna untuk item ini

    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        lhs.id == rhs.id
    }
}