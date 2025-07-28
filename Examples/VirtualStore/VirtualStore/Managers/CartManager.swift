import Foundation
import StoreKit
import SwiftUI

class CartManager: ObservableObject {
    @Published var cart: [CartItem] = []
    @Published var isLoading = false
    
    // Add to cart
    func addToCart(product: Product) {  
        DispatchQueue.main.async {
            if let index = self.cart.firstIndex(where: { $0.product.id == product.id }) {
                self.cart[index].quantity += 1
                
                // Send event for updating cart quantity
                TrackingManager.shared.trackEvent(
                    name: Constants.Events.updateCartQuantity,
                    parameters: [
                        "product_id": product.id,
                        "product_name": product.name,
                        "revenue": product.price, // Use revenue for better conversion tracking
                        "quantity": self.cart[index].quantity
                    ]
                )
            } else {
                self.cart.append(CartItem(product: product, quantity: 1))
                
                // Send event for adding to cart with revenue
                TrackingManager.shared.trackEvent(
                    name: Constants.Events.addToCart,
                    parameters: [
                        "product_id": product.id,
                        "product_name": product.name,
                        "revenue": product.price // Use revenue parameter for conversion tracking
                    ]
                )
            }
        }
    }
    
    // Remove from cart
    func removeFromCart(productId: String) {
        if let index = cart.firstIndex(where: { $0.product.id == productId }) {
            let product = cart[index].product
            
            // Send event for removing from cart
            TrackingManager.shared.trackEvent(
                name: Constants.Events.removeFromCart,
                parameters: [
                    "product_id": product.id,
                    "product_name": product.name,
                    "revenue": product.price
                ]
            )
            cart.remove(at: index)
        }
    }
    
    func updateQuantity(productId: String, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.product.id == productId }) {
            let newQuantity = max(1, quantity)
            cart[index].quantity = newQuantity
            
            // Send event for updating cart quantity
            TrackingManager.shared.trackEvent(
                name: Constants.Events.updateCartQuantity,
                parameters: [
                    "product_id": cart[index].product.id,
                    "product_name": cart[index].product.name,
                    "revenue": cart[index].product.price,
                    "quantity": newQuantity
                ]
            )
        }
    }
    
    func purchase() {
        isLoading = true
        
        let totalValue = cartTotal
        let items = cart.map { 
            [
                "id": $0.product.id,
                "name": $0.product.name,
                "price": $0.product.price,
                "quantity": $0.quantity
            ] 
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Send purchase event with total revenue
            // This is the most important event for conversion tracking
            TrackingManager.shared.trackEvent(
                name: Constants.Events.purchase,
                parameters: [
                    "revenue": totalValue, // Primary revenue parameter for conversion tracking
                    "currency": "USD",
                    "items": items,
                    "item_count": self.cart.count
                ]
            )
            
            self.cart.removeAll()
            self.isLoading = false
        }
    }
    
    var cartTotal: Double {
        return cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    var formattedCartTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.positivePrefix = "$"
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: NSNumber(value: cartTotal)) ?? "$\(cartTotal)"
    }
    
    var totalItems: Int {
        return cart.reduce(0) { $0 + $1.quantity }
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}
