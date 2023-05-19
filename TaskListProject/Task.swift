import Foundation
import FirebaseFirestoreSwift

struct Task:Codable {
    // properties in the document
    // - names of the properties match the name of the keys in the document
    @DocumentID var id:String?
    var name:String = ""
    var isHighPriority:Bool = false
}
