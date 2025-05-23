import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel

    init(authManager: AuthenticationManager) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authManager: authManager))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("EatEase Login")
                .font(.largeTitle)
                .fontWeight(.bold)	
                .padding(.bottom, 30)

            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .multilineTextAlignment(.center)
            }

            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 20)
            } else {
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

//                Button(action: {
//                    viewModel.signUp()
//                }) {
//                    Text("Buat Akun Baru")
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(8)
//                }
            }
            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authManager: AuthenticationManager())
    }
}
