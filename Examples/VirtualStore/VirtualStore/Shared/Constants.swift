import Foundation
import AppstackSDK

struct Constants {
    
    // MARK: - SDK Configuration
    // Replace with your actual Appstack api key from the dashboard
    // Get your key from: https://dashboard.appstack.com/settings
    //#error("Modify the appstack api key in Constants.swift, then comment this line out.")
    static let appstackApiKey = "YOUR_APPSTACK_API_KEY"
    
    // Replace with your actual App ID for Meta/Facebook SDK
    static let appId = "YOUR_APP_ID"
    
    // Replace with your actual TikTok App ID
    static let tiktokAppId = "YOUR_TIKTOK_APP_ID"
    
    // MARK: - Event Types and Names
    // Mapping of events to the new EventType enum and custom event names
    struct Events {
        // Standard events using EventType enum
        static let signup = EventType.LOGIN  // Using LOGIN for signup events
        static let login = EventType.LOGIN
        static let purchase = EventType.PURCHASE
        
        // Custom events (using EventType.CUSTOM with custom names)
        static let viewProductList = "view_product_list"
        static let viewProduct = "view_product"
        static let addToCart = "add_to_cart"
        static let viewCart = "view_cart"
        static let logout = "logout"
        static let removeFromCart = "remove_from_cart"
        static let updateCartQuantity = "update_cart_quantity"
        static let viewSignup = "view_signup"
        static let viewHome = "view_home"
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
