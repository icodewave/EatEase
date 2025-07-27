//
//  Order.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String? // ID Dokumen Order di Firestore
    var userId: String          // ID kasir/user yang membuat order
    var items: [OrderItem]
    var createdAt: Timestamp
    var updatedAt: Timestamp    // Tambahkan ini untuk best practice
    var namaPelanggan: String
    var nomorMeja: String       // Bisa juga Int, tapi String lebih fleksibel (misal "Take Away")
    var metodePembayaran: String
    var status: String          // Contoh: "pending", "diproses", "selesai", "dibatalkan"
    var totalAmount: Double     // Total harga order

    // Anda bisa menambahkan field lain seperti diskon total, pajak, dll.
}
