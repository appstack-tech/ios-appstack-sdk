import Foundation

struct Constants {
    
//#error("Modify the appstack verification key in Constants.swift, then comment this line out.")
    static let appstackVerificationKey = "YOUR_APPSTACK_VERIFICATION_KEY"
//#error("Modify the appId in Constants.swift, then comment this line out.")
    static let appId = "YOUR_APP_ID"
//#error("Modify the tiktokAppId in Constants.swift, then comment this line out.")
    static let tiktokAppId = "YOUR_TIKTOK_APP_ID"
    
    // Event names
    struct Events {
        static let signup = "signup"
        static let login = "login"
        static let viewProductList = "view_product_list"
        static let viewProduct = "view_product"
        static let addToCart = "add_to_cart"
        static let purchase = "purchase"
        static let viewCart = "view_cart"
        static let logout = "logout"
        static let removeFromCart = "remove_from_cart"
        static let updateCartQuantity = "update_cart_quantity"
        static let viewSignup = "view_signup"
        static let viewHome = "view_home"
    }
    
    // Sample products with details
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
