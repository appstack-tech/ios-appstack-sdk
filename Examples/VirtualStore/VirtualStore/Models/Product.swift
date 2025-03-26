import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let image: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.positivePrefix = "$"
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
} 