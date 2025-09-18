import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @State private var showingAddedToCart = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                        
                        Image(systemName: product.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom)
                    
                    Group {
                        Text(product.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(product.formattedPrice)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        
                        Text("Description")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "checkmark.circle.fill", text: "2-year warranty")
                            FeatureRow(icon: "shippingbox.fill", text: "Free shipping")
                            FeatureRow(icon: "arrow.clockwise.circle.fill", text: "30-day returns")
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 80)
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    withAnimation {
                        cartManager.addToCart(product: product)
                        showingAddedToCart = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingAddedToCart = false
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if cartManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Image(systemName: "cart.badge.plus")
                                .font(.title3)
                            Text("Add to Cart")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.orange.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .padding(.top, 10)
                .disabled(cartManager.isLoading)
                .background(Color.white)
            }
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CartView()
                        .onAppear {
                            // Send cart view event
                            TrackingManager.shared.trackEvent(
                                eventType: .CUSTOM,
                                customEventName: Constants.Events.viewCart
                            )
                        }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                            .font(.title3)
                        
                        if cartManager.totalItems > 0 {
                            Text("\(cartManager.totalItems)")
                                .font(.caption2)
                                .padding(5)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        }
                    }
                }
            }
        }
        .overlay(
            showingAddedToCart ? 
                VStack {
                    Spacer()
                    Text("Added to cart!")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom))
                }
                .animation(.spring(), value: showingAddedToCart)
                : nil
        )
    }
}

// Component to display product features
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: Constants.products[0])
            .environmentObject(CartManager())
    }
}
