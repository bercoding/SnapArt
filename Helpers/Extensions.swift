import SwiftUI
import CoreData

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - NSManagedObject Extensions
extension NSManagedObject {
    func toJSON() -> [String: Any] {
        var dict = [String: Any]()
        
        for attribute in entity.attributesByName {
            if let value = value(forKey: attribute.key) {
                dict[attribute.key] = value
            }
        }
        
        return dict
    }
}

// MARK: - Color Extensions
extension Color {
    static let snapBlue = Color("SnapBlue", bundle: nil)
    static let snapBackground = Color("SnapBackground", bundle: nil)
}

// MARK: - UIImage Extensions
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
} 