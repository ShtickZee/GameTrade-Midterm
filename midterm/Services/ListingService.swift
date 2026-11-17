import Foundation
import FirebaseFirestore

final class ListingService {
    static let shared = ListingService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchListings(completion: @escaping (Result<[Listing], Error>) -> Void) {
        db.collection("listings").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let listings = snapshot?.documents.compactMap { doc -> Listing? in
                try? doc.data(as: Listing.self)
            } ?? []
            
            completion(.success(listings))
        }
    }
}
