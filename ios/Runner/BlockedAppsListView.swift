//
//  BlockedAppsListView.swift
//  Runner
//
//  SwiftUI view to display blocked apps with their icons
//

import SwiftUI
import FamilyControls

/// Hosting controller for BlockedAppsListView
@available(iOS 16.0, *)
class BlockedAppsHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

/// SwiftUI view displaying the list of blocked apps with icons
@available(iOS 16.0, *)
struct BlockedAppsListView: View {
    let selection: FamilyActivitySelection
    var onEditTapped: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header info
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)

                        Text("Blocked Apps")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("These apps will be blocked during your scheduled focus times")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Apps section
                    if !selection.applicationTokens.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "app.fill")
                                    .foregroundColor(.blue)
                                Text("Apps (\(selection.applicationTokens.count))")
                                    .font(.headline)
                            }
                            .padding(.horizontal)

                            // Grid of app icons
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12)
                            ], spacing: 16) {
                                ForEach(Array(selection.applicationTokens), id: \.self) { token in
                                    VStack(spacing: 6) {
                                        Label(token)
                                            .labelStyle(.iconOnly)
                                            .scaleEffect(1.5)
                                            .frame(width: 50, height: 50)

                                        Label(token)
                                            .labelStyle(.titleOnly)
                                            .font(.caption2)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 70)
                                    }
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }

                    // Categories section
                    if !selection.categoryTokens.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                    .foregroundColor(.purple)
                                Text("Categories (\(selection.categoryTokens.count))")
                                    .font(.headline)
                            }
                            .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12)
                            ], spacing: 16) {
                                ForEach(Array(selection.categoryTokens), id: \.self) { token in
                                    VStack(spacing: 6) {
                                        Label(token)
                                            .labelStyle(.iconOnly)
                                            .scaleEffect(1.5)
                                            .frame(width: 50, height: 50)

                                        Label(token)
                                            .labelStyle(.titleOnly)
                                            .font(.caption2)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 70)
                                    }
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }

                    // Web domains section
                    if !selection.webDomainTokens.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.green)
                                Text("Websites (\(selection.webDomainTokens.count))")
                                    .font(.headline)
                            }
                            .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 12)
                            ], spacing: 16) {
                                ForEach(Array(selection.webDomainTokens), id: \.self) { token in
                                    VStack(spacing: 6) {
                                        Label(token)
                                            .labelStyle(.iconOnly)
                                            .scaleEffect(1.5)
                                            .frame(width: 50, height: 50)

                                        Label(token)
                                            .labelStyle(.titleOnly)
                                            .font(.caption2)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 70)
                                    }
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }

                    // Edit button
                    Button(action: {
                        dismiss()
                        // Small delay to let the sheet dismiss first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onEditTapped?()
                        }
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                            Text("Edit Selection")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onEditTapped?()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
