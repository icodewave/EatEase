//
//  Cart.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import Foundation
import FirebaseFirestore

struct Cart: Identifiable, Codable {
    @DocumentID var id: String? // ID Dokumen Cart di Firestore
    var userId: String
    var items: [CartItem]
    var createdAt: Timestamp
    var updatedAt: Timestamp
    // Anda bisa menambahkan properti lain seperti totalAmount, status, dll.

    // Helper untuk menghitung total harga
    var totalAmount: Double {
        items.reduce(0) { $0 + ($1.harga * Double($1.kuantitas)) }
    }
    
    // Helper untuk menghitung total item
    var totalItemsQuantity: Int {
        items.reduce(0) { $0 + $1.kuantitas }
    }
}
