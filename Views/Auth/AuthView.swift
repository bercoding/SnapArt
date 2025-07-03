import SwiftUI

struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegister: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "camera.on.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text(isRegister ? "Tạo tài khoản" : "Đăng nhập")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                SecureField("Mật khẩu", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                if let message = errorMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: authAction) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isRegister ? "Đăng ký" : "Đăng nhập")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                
                Button(action: { isRegister.toggle() }) {
                    Text(isRegister ? "Đã có tài khoản? Đăng nhập" : "Chưa có tài khoản? Đăng ký")
                        .font(.footnote)
                }
                .disabled(isLoading)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func authAction() {
        errorMessage = nil
        isLoading = true
        
        if isRegister {
            firebaseManager.signUp(email: email, password: password) { result in
                isLoading = false
                switch result {
                case .success(_):
                    // Auto-login will happen via FirebaseManager's Auth listener
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            firebaseManager.signIn(email: email, password: password) { result in
                isLoading = false
                switch result {
                case .success(_):
                    // Auto-login will happen via FirebaseManager's Auth listener
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AuthView()
} 
