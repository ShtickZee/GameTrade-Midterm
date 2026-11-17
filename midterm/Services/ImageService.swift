import UIKit

class ImageService {
    static func saveImageLocally(_ image: UIImage) -> String? {
        // Mock implementation: just return a dummy path
        return "local_image_\(UUID().uuidString)"
    }
}
