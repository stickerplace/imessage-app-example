import Foundation

extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension Array where Element: NSObject {

    func compareStickersArrays(_ arr2: [NSObject]) -> Bool {
        return self.count == arr2.count && !zip(self, arr2).contains { !($0 == $1) }
    }
    
}
