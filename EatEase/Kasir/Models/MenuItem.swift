//
//  MenuItem.swift
//  EatEase
//
//  Created by iCodeWave Community on 26/05/25.
//


// EatEase/Kasir/Models/MenuItem.swift (atau lokasi lain yang sesuai)
import FirebaseFirestore // Penting untuk @DocumentID

struct MenuItem: Identifiable, Codable, Hashable { // Tambahkan Hashable jika akan digunakan di NavigationStack
    @DocumentID var id: String? // Otomatis diisi oleh Firestore
    var nama: String
    var harga: Double // Gunakan Double untuk harga agar lebih fleksibel
    var kategori: String
    var desc: String
    // 'stok' tidak ada di struktur Firestore Anda, jadi tidak dimasukkan di sini.
    // Jika ada URL gambar, tambahkan properti seperti 'gambarUrl: String?'
}
