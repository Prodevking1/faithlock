//
//  FamilyActivityPickerViewController.swift
//  Runner
//
//  Created by Abdoul Rachid Tapsoba on 14/10/2025.
//

import UIKit
import SwiftUI
import FamilyControls

@available(iOS 16.0, *)
class FamilyActivityPickerViewController: UIViewController {

    private var onSelection: ((FamilyActivitySelection) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create SwiftUI view
        let pickerView = FamilyActivityPickerView { [weak self] selection in
            self?.onSelection?(selection)
            self?.dismiss(animated: true)
        }

        // Host SwiftUI view in UIViewController
        let hostingController = UIHostingController(rootView: pickerView)
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    func setOnSelection(_ callback: @escaping (FamilyActivitySelection) -> Void) {
        self.onSelection = callback
    }
}

@available(iOS 16.0, *)
struct FamilyActivityPickerView: View {
    @State private var selection = FamilyActivitySelection()
    var onSelection: (FamilyActivitySelection) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Apps to Block")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Choose which apps and categories you want to block during lock schedules")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                FamilyActivityPicker(selection: $selection)
                    .padding()

                Spacer()

                HStack(spacing: 16) {
                    Button("Cancel") {
                        onSelection(FamilyActivitySelection())
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Button("Done") {
                        onSelection(selection)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
