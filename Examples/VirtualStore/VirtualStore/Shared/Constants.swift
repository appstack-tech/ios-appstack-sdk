import Foundation
import AppstackSDK

struct Constants {

    // MARK: - SDK Configuration
    // Replace with your actual Appstack API key from the dashboard.
    // Get your key from: https://dashboard.appstack.com/settings
    //#error("Modify the appstack api key in Constants.swift, then comment this line out.")
    static let appstackApiKey = "YOUR_APPSTACK_API_KEY"

    // MARK: - Events
    // This example tracks the funnel using only the Appstack SDK's standard `EventType`
    // values — Appstack maps these to the canonical events every ad network understands.
    // (`.CUSTOM` events are supported by the SDK for app-specific actions, but this demo
    // deliberately avoids them.)
    //
    // Note: INSTALL, FIRST_OPEN, and StoreKit purchases are tracked automatically by the SDK
    // and are intentionally NOT listed here.
    struct Events {
        static let signup = EventType.SIGN_UP
        static let viewProduct = EventType.VIEW_ITEM
        static let addToCart = EventType.ADD_TO_CART
        static let initiateCheckout = EventType.INITIATE_CHECKOUT
        static let purchase = EventType.PURCHASE
    }

    // MARK: - Sample Products
    // Sample products with details for demonstration
    static let products: [Product] = [
        Product(
            id: "1",
            name: "Premium Smartphone",
            price: 999.99,
            description: "The latest smartphone with high-resolution camera and long-lasting battery.",
            image: "smartphone"
        ),
        Product(
            id: "2",
            name: "Ultralight Laptop",
            price: 1299.99,
            description: "Powerful and lightweight laptop, perfect for professionals on the move.",
            image: "laptopcomputer"
        ),
        Product(
            id: "3",
            name: "Wireless Headphones",
            price: 199.99,
            description: "Headphones with noise cancellation and exceptional sound quality.",
            image: "headphones"
        ),
        Product(
            id: "4",
            name: "Sports Smartwatch",
            price: 299.99,
            description: "Smart watch with fitness tracking and notifications.",
            image: "applewatch"
        ),
        Product(
            id: "5",
            name: "DSLR Camera",
            price: 799.99,
            description: "Professional camera to capture special moments with exceptional quality.",
            image: "camera"
        )
    ]
}
