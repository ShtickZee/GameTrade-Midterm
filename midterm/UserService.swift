import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class UserService {
    static let shared = UserService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Atomic Public + Private Profile Save
    
    /// Saves the user's public profile to `users/{uid}` and private sensitive fields to
    /// `users/{uid}/private/sensitive` using an atomic Firestore WriteBatch.
    func saveUserProfile(
        uid: String,
        name: String?,
        handle: String,
        email: String,
        phone: String,
        rawLocation: String,
        bio: String,
        profileImage: UIImage?,
        existingAvatarURL: String?,
        completion: @escaping (Result<(PublicUserProfile, PrivateUserData), Error>) -> Void
    ) {
        let proceedWithSave: (String?) -> Void = { [weak self] uploadedAvatarURL in
            guard let self = self else { return }
            
            let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let optionalName: String? = (cleanName?.isEmpty == false) ? cleanName : nil
            
            let formattedHandle: String = {
                let stripped = handle.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "@", with: "")
                return stripped.isEmpty ? "@trader_\(uid.prefix(5))" : "@\(stripped)"
            }()
            
            let coarseLocation = SecurityUtils.extractCoarseLocation(from: rawLocation)
            let normalizedPhone = SecurityUtils.normalizePhone(phone)
            let now = Date().timeIntervalSince1970
            
            let publicProfile = PublicUserProfile(
                id: uid,
                name: optionalName,
                handle: formattedHandle,
                bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                coarseLocation: coarseLocation,
                avatarURL: uploadedAvatarURL ?? existingAvatarURL,
                role: .standardUser,
                rating: 5.0,
                reviewsCount: 0,
                verified: true,
                listingsCount: 0,
                soldCount: 0,
                createdAt: now
            )
            
            let privateData = PrivateUserData(
                uid: uid,
                email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                emailHash: SecurityUtils.sha256(email),
                phoneNumber: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneHash: normalizedPhone.isEmpty ? "" : SecurityUtils.sha256(normalizedPhone),
                exactLocation: rawLocation.trimmingCharacters(in: .whitespacesAndNewlines),
                updatedAt: now
            )
            
            let publicRef = self.db.collection("users").document(uid)
            let privateRef = publicRef.collection("private").document("sensitive")
            
            let batch = self.db.batch()
            
            let publicDict: [String: Any] = [
                "id": publicProfile.id,
                "name": publicProfile.name as Any,
                "handle": publicProfile.handle,
                "bio": publicProfile.bio,
                "coarseLocation": publicProfile.coarseLocation,
                "avatarURL": publicProfile.avatarURL as Any,
                "role": publicProfile.role.rawValue,
                "rating": publicProfile.rating,
                "reviewsCount": publicProfile.reviewsCount,
                "verified": publicProfile.verified,
                "listingsCount": publicProfile.listingsCount,
                "soldCount": publicProfile.soldCount,
                "createdAt": publicProfile.createdAt
            ]
            
            let privateDict: [String: Any] = [
                "uid": privateData.uid,
                "email": privateData.email,
                "emailHash": privateData.emailHash,
                "phoneNumber": privateData.phoneNumber,
                "phoneHash": privateData.phoneHash,
                "exactLocation": privateData.exactLocation,
                "updatedAt": privateData.updatedAt
            ]
            
            batch.setData(publicDict, forDocument: publicRef, merge: true)
            batch.setData(privateDict, forDocument: privateRef, merge: true)
            
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success((publicProfile, privateData)))
                }
            }
        }
        
        if let image = profileImage {
            uploadAvatar(uid: uid, image: image) { result in
                switch result {
                case .success(let url):
                    proceedWithSave(url)
                case .failure:
                    // Even if image upload fails (e.g., Storage not yet enabled), still save profile data
                    proceedWithSave(existingAvatarURL)
                }
            }
        } else {
            proceedWithSave(existingAvatarURL)
        }
    }
    
    // MARK: - Fetch Current Authenticated User (Public + Private)
    
    func fetchCurrentUserProfile(
        uid: String,
        completion: @escaping (PublicUserProfile?, PrivateUserData?) -> Void
    ) {
        let publicRef = db.collection("users").document(uid)
        let privateRef = publicRef.collection("private").document("sensitive")
        
        let group = DispatchGroup()
        var fetchedPublic: PublicUserProfile?
        var fetchedPrivate: PrivateUserData?
        
        group.enter()
        publicRef.getDocument { snapshot, _ in
            defer { group.leave() }
            guard let data = snapshot?.data() else { return }
            fetchedPublic = PublicUserProfile(
                id: data["id"] as? String ?? uid,
                name: data["name"] as? String,
                handle: data["handle"] as? String ?? "@trader",
                bio: data["bio"] as? String ?? "",
                coarseLocation: data["coarseLocation"] as? String ?? "Undisclosed",
                avatarURL: data["avatarURL"] as? String,
                role: UserRole(rawValue: data["role"] as? String ?? "standard_user") ?? .standardUser,
                rating: data["rating"] as? Double ?? 5.0,
                reviewsCount: data["reviewsCount"] as? Int ?? 0,
                verified: data["verified"] as? Bool ?? false,
                listingsCount: data["listingsCount"] as? Int ?? 0,
                soldCount: data["soldCount"] as? Int ?? 0,
                createdAt: data["createdAt"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
        }
        
        group.enter()
        privateRef.getDocument { snapshot, _ in
            defer { group.leave() }
            guard let data = snapshot?.data() else { return }
            fetchedPrivate = PrivateUserData(
                uid: data["uid"] as? String ?? uid,
                email: data["email"] as? String ?? "",
                emailHash: data["emailHash"] as? String ?? "",
                phoneNumber: data["phoneNumber"] as? String ?? "",
                phoneHash: data["phoneHash"] as? String ?? "",
                exactLocation: data["exactLocation"] as? String ?? "",
                updatedAt: data["updatedAt"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
        }
        
        group.notify(queue: .main) {
            completion(fetchedPublic, fetchedPrivate)
        }
    }
    
    // MARK: - Upload Avatar to Firebase Storage
    
    private func uploadAvatar(
        uid: String,
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.65) else {
            completion(.failure(NSError(domain: "GameTrade", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image."])))
            return
        }
        
        let avatarRef = storage.reference().child("avatars/\(uid)/profile.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            avatarRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                }
            }
        }
    }
}
