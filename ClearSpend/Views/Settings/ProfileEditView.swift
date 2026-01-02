//
//  ProfileEditView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var userProfile: UserProfile?
    @State private var name: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Profile Image Section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Text("Profile Photo")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.surfaceVariant)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                                )
                            
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else if let imageData = userProfile?.profileImageData,
                                      let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                            
                            // Camera button overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        ZStack {
                                            Circle()
                                                .fill(DesignSystem.Colors.primary)
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .offset(x: 8, y: 8)
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .cardStyle()
                    
                    // Name Section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Display Name")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        TextField("Enter your name", text: $name)
                            .font(DesignSystem.Typography.bodyMedium)
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.surfaceVariant)
                            )
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .cardStyle()
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .disabled(name.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { 
                        dismiss() 
                    }
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .onAppear {
            loadUserProfile()
        }
        .onChange(of: selectedPhoto) { _, newValue in
            loadSelectedPhoto()
        }
    }
    
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
        
        if let userProfile = userProfile {
            name = userProfile.name
        }
    }
    
    private func loadSelectedPhoto() {
        Task {
            if let selectedPhoto = selectedPhoto {
                if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    profileImage = UIImage(data: data)
                }
            }
        }
    }
    
    private func saveProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        let profile = (try? modelContext.fetch(descriptor).first) ?? UserProfile()
        
        if userProfile == nil {
            modelContext.insert(profile)
        }
        
        let imageData = profileImage?.pngData()
        profile.updateProfile(name: name, profileImageData: imageData)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
