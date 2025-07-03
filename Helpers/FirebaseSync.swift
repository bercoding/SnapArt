import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import CoreData

class FirebaseSync {
    static let shared = FirebaseSync()
    
    private let db = Firestore.firestore()
    private let persistenceController = PersistenceController.shared
    
    private init() {}
    
    // MARK: - Image Syncing
    
    func syncImageToFirebase(image: EditedImage) {
        guard let imageId = image.id?.uuidString,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        // Create dictionary of image data
        var imageData: [String: Any] = [
            "id": imageId,
            "title": image.title ?? "Untitled",
            "createdAt": image.createdAt ?? Date(),
            "updatedAt": image.updatedAt ?? Date(),
            "userId": userId
        ]
        
        // Width and height are not optional in the Core Data model, so direct access
        imageData["width"] = image.width
        imageData["height"] = image.height
        
        // Add to Firestore
        db.collection("users").document(userId)
            .collection("editedImages").document(imageId)
            .setData(imageData) { error in
                if let error = error {
                    print("Error saving image to Firebase: \(error.localizedDescription)")
                } else {
                    print("Successfully saved image to Firebase")
                    
                    // Upload actual image data to Firebase Storage if needed
                    // self.uploadImageData(image: image)
                }
            }
    }
    
    func fetchImagesFromFirebase(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion()
            return
        }
        
        let context = persistenceController.container.viewContext
        
        db.collection("users").document(userId)
            .collection("editedImages")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion()
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    
                    // Check if image already exists in Core Data
                    if let imageId = data["id"] as? String,
                       let uuid = UUID(uuidString: imageId) {
                        
                        // Try to find existing image
                        let fetchRequest: NSFetchRequest<EditedImage> = EditedImage.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
                        
                        do {
                            let results = try context.fetch(fetchRequest)
                            let editedImage: EditedImage
                            
                            if let existingImage = results.first {
                                // Update existing image
                                editedImage = existingImage
                            } else {
                                // Create new image
                                editedImage = EditedImage(context: context)
                                editedImage.id = uuid
                            }
                            
                            // Update properties
                            if let title = data["title"] as? String {
                                editedImage.title = title
                            }
                            
                            if let createdTimestamp = data["createdAt"] as? Timestamp {
                                editedImage.createdAt = createdTimestamp.dateValue()
                            }
                            
                            if let updatedTimestamp = data["updatedAt"] as? Timestamp {
                                editedImage.updatedAt = updatedTimestamp.dateValue()
                            }
                            
                            if let width = data["width"] as? Int32 {
                                editedImage.width = width
                            }
                            
                            if let height = data["height"] as? Int32 {
                                editedImage.height = height
                            }
                            
                            // Save changes
                            try context.save()
                            
                        } catch {
                            print("Error fetching/saving image: \(error)")
                        }
                    }
                }
                completion()
            }
    }
    
    // Add more syncing methods for User, Filter, etc.
} 