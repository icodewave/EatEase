//
//  Loginscreen.swift
//  EatEase
//
//  Created by iCodeWave Community on 20/05/25.
//

import SwiftUI

struct Loginscreen: View {
    var body: some View {
        VStack {
            NavigationLink {
                Text("Sign Up")
            } label: {
                 Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            
            
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct Loginscreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Loginscreen()
        }
    }
}
