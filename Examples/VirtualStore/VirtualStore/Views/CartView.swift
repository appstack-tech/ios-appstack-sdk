import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showingPurchaseConfirmation = false
    @State private var lastPurchaseTotal = ""
    
    var body: some View {
        ZStack {
            // Main cart view
            VStack {
                if cartManager.cart.isEmpty {
                    // Empty cart
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "cart.badge.minus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add products from the store to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // List of products in cart
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(cartManager.cart) { item in
                                CartItemRow(item: item)
                            }
                        }
                        .padding()
                    }
                    
                    // Cart summary
                    VStack(spacing: 15) {
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(cartManager.formattedCartTotal)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        // Checkout button
                        Button {
                            lastPurchaseTotal = cartManager.formattedCartTotal
                            cartManager.purchase()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                showingPurchaseConfirmation = true
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if cartManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.2)
                                    Text("Processing payment...")
                                        .fontWeight(.semibold)
                                        .padding(.leading, 8)
                                } else {
                                    Image(systemName: "creditcard.fill")
                                    Text("Pay")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(cartManager.isLoading ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .disabled(cartManager.isLoading)
                    }
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
                }
            }
            .navigationTitle("Cart")
            
            // Purchase confirmation message
            if showingPurchaseConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showingPurchaseConfirmation = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                            
                            Text("Purchase completed successfully!")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Thank you for your purchase")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack {
                                Text("Total:")
                                    .foregroundColor(.white.opacity(0.9))
                                Text(lastPurchaseTotal)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 5)
                                
                            Divider()
                                .background(Color.white.opacity(0.5))
                                .padding(.vertical, 5)
                                
                            Text("You will receive an email with the details of your order")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                
                            Button {
                                withAnimation {
                                    showingPurchaseConfirmation = false
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                        .font(.body)
                                    Text("Accept")
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                                )
                                .foregroundColor(.green)
                            }
                            .padding(.top, 15)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green)
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 100)
                        .transition(.scale.combined(with: .opacity))
                        .contentShape(Rectangle())
                        .onTapGesture { }
                        
                        Spacer()
                    }
                }
                .zIndex(1)
                .animation(.spring(), value: showingPurchaseConfirmation)
                .transition(.opacity)
            }
        }
    }
}

// Component to display a product in the cart
struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: item.product.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.product.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(item.product.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Bottom section with controls
            HStack {
                HStack(spacing: 12) {
                    Text("Quantity:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        if item.quantity > 1 {
                            cartManager.updateQuantity(productId: item.product.id, quantity: item.quantity - 1)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .frame(minWidth: 20)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        cartManager.updateQuantity(productId: item.product.id, quantity: item.quantity + 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button {
                    cartManager.removeFromCart(productId: item.product.id)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                        
                        Text("Remove")
                            .font(.subheadline)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        CartView()
            .environmentObject(CartManager())
    }
}
