import Foundation
import Firebase
import FirebaseAuth
import Combine

final class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // Published Firebase user
    @Published var user: FirebaseAuth.User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    // MARK: - Auth APIs
    func signUp(email: String, password: String, completion: @escaping (Result<FirebaseAuth.AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
} 