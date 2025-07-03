//
//  ContentView.swift
//  SnapArt
//
//  Created by Le Thanh Nhan on 2/7/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EditedImage.createdAt, ascending: false)],
        animation: .default)
    private var editedImages: FetchedResults<EditedImage>

    var body: some View {
        NavigationView {
            List {
                ForEach(editedImages) { image in
                    NavigationLink {
                        ImageDetailView(image: image)
                    } label: {
                        HStack {
                            if let imageData = image.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(image.title ?? "Untitled")
                                    .font(.headline)
                                
                                if let date = image.createdAt {
                                    Text(date, formatter: itemFormatter)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteImages)
            }
            .navigationTitle("SnapArt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNewImage) {
                        Label("Add Image", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: signOut) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            Text("Chọn ảnh để xem chi tiết")
                .foregroundColor(.gray)
        }
    }
    
    private func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func addNewImage() {
        withAnimation {
            let newImage = EditedImage(context: viewContext)
            newImage.id = UUID()
            newImage.title = "Ảnh mới"
            newImage.createdAt = Date()
            newImage.updatedAt = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteImages(offsets: IndexSet) {
        withAnimation {
            offsets.map { editedImages[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ImageDetailView: View {
    let image: EditedImage
    
    var body: some View {
        VStack {
            if let imageData = image.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .foregroundColor(.gray)
            }
            
            Text(image.title ?? "Untitled")
                .font(.title)
            
            if let date = image.createdAt {
                Text("Created: \(date, formatter: itemFormatter)")
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle(image.title ?? "Image Details")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
