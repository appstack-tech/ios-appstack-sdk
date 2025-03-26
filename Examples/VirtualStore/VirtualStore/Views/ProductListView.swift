//
//  ProductListView.swift
//  VirtualStore
//
//  Created by ANTONIO JIMÉNEZ MARTÍNEZ on 14/3/25.
//

import SwiftUI

struct ProductListView: View {
    // Use sample products from Constants
    let products = Constants.products
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                            .onAppear {
                                // Send detailed product view event
                                TrackingManager.shared.trackEvent(
                                    name: Constants.Events.viewProduct,
                                    parameters: [
                                        "product_id": product.id,
                                        "product_name": product.name,
                                        "price": product.price
                                    ]
                                )
                            }
                    } label: {
                        ProductRow(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CartView()
                        .onAppear {
                            // Send cart view event
                            TrackingManager.shared.trackEvent(name: Constants.Events.viewCart)
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
    }
}

// Component to display a product row
struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: product.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        ProductListView()
            .environmentObject(CartManager())
    }
}
