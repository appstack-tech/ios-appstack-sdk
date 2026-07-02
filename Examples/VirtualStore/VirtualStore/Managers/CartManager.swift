import Foundation
import SwiftUI

class CartManager: ObservableObject {
    @Published var cart: [CartItem] = []
    @Published var isLoading = false

    // Add to cart
    func addToCart(product: Product) {
        DispatchQueue.main.async {
            if let index = self.cart.firstIndex(where: { $0.product.id == product.id }) {
                self.cart[index].quantity += 1
            } else {
                self.cart.append(CartItem(product: product, quantity: 1))
            }

            // Standard ADD_TO_CART event with revenue for ROAS optimization.
            TrackingManager.shared.trackEvent(
                event: Constants.Events.addToCart,
                parameters: [
                    "product_id": product.id,
                    "product_name": product.name,
                    "revenue": product.price,
                    "currency": "USD"
                ]
            )
        }
    }

    // Remove from cart (cart management — no attribution event fired)
    func removeFromCart(productId: String) {
        cart.removeAll { $0.product.id == productId }
    }

    // Update quantity from the cart steppers (cart management — no attribution event fired)
    func updateQuantity(productId: String, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.product.id == productId }) {
            cart[index].quantity = max(1, quantity)
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
            // Standard PURCHASE event with total revenue.
            //
            // NOTE: This example simulates checkout, so we send PURCHASE manually. In a real
            // app that uses StoreKit / in-app purchases, the Appstack SDK captures purchases
            // automatically — you would not send this event yourself.
            TrackingManager.shared.trackEvent(
                event: Constants.Events.purchase,
                parameters: [
                    "revenue": totalValue,
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
