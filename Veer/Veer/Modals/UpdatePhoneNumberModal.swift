//
//  UpdatePhoneNumberModal.swift
//  Veer
//
//  Created by Apple on 9/23/25.
//

import SwiftUI

struct UpdatePhoneNumberModal: View {
    @Binding var isPresented: Bool
    @State private var phoneNumber = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Update Phone Number")
                    .font(.title3.bold())
                    .padding(.top, 10)
                
                Text("Your phone number is used as an alternative means of ID.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("A verification code will be sent to this number")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: updatePhone) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Update Phone Number")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isLoading)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Close") {
                isPresented = false
            })
        }
    }
    
    private func updatePhone() {
        // TODO: Call API
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isPresented = false
        }
    }
}
