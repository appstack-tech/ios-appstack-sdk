import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Virtual Store")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Register to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 30)
            
            // Form fields
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button {
                Task {
                    await authManager.login()
                }
            } label: {
                HStack {
                    Spacer()
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else {
                        Text("Register")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(authManager.isLoading)
            
            Spacer()
            
            Text("By registering, you agree to our terms and privacy policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
            // Send signup view event
            TrackingManager.shared.trackEvent(
                eventType: .CUSTOM,
                customEventName: Constants.Events.viewSignup
            )
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthManager())
}
