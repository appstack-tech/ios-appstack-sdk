import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), 
                               startPoint: .top, 
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text("Welcome to")
                            .font(.title2)
                        Text("Virtual Store")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 30)
                    
                    Image(systemName: "bag.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.vertical, 20)
                    
                    VStack(spacing: 15) {
                        NavigationLink {
                            ProductListView()
                                .onAppear {
                                    // Send product view event
                                    TrackingManager.shared.trackEvent(name: Constants.Events.viewProductList)
                                }
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.title3)
                                Text("View Products")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        NavigationLink {
                            CartView()
                                .onAppear {
                                    // Send cart view event
                                    TrackingManager.shared.trackEvent(name: Constants.Events.viewCart)
                                }
                        } label: {
                            HStack {
                                Image(systemName: "cart")
                                    .font(.title3)
                                Text("View Cart")
                                    .fontWeight(.semibold)
                                Spacer()
                                if cartManager.totalItems > 0 {
                                    Text("\(cartManager.totalItems)")
                                        .font(.caption)
                                        .padding(8)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.green)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        authManager.logout()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Logout")
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .disabled(authManager.isLoading)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear {
                // Send home view event
                TrackingManager.shared.trackEvent(name: Constants.Events.viewHome)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(CartManager())
}
