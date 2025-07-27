//
//  MenuItemRow.swift
//  EatEase
//
//  Created by iCodeWave Community on 28/05/25.
//


import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack {
            Image(item.imageName) // Placeholder
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .padding(.trailing, 8)

            VStack(alignment: .leading) {
                Text(item.nama)
                    .font(.headline)
                Text("Rp \(Int(item.harga))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
