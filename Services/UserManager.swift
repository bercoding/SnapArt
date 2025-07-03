import Foundation
import FirebaseAuth
import CoreData

class UserManager {
    static let shared = UserManager()
    
    private let persistenceController = PersistenceController.shared
    
    private init() {
        // Setup observers for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.handleUserSignIn(user)
            } else {
                // User signed out
            }
        }
    }
    
    private func handleUserSignIn(_ firebaseUser: FirebaseAuth.User) {
        // Update or create Core Data user
        persistenceController.saveUserData(for: firebaseUser)
        
        // Fetch user's images from Firebase
        FirebaseSync.shared.fetchImagesFromFirebase {
            // Completed fetching images
        }
    }
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", firebaseUser.uid)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching current user: \(error)")
            return nil
        }
    }
    
    func linkUserToEditedImage(_ image: EditedImage) {
        guard let currentUser = getCurrentUser() else { return }
        
        let context = persistenceController.container.viewContext
        
        // This would work if User and EditedImage had a relationship
        // In this simplified model we're just syncing to Firebase directly
        
        // Update Firebase
        FirebaseSync.shared.syncImageToFirebase(image: image)
    }
} 