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
    private var initialSelection: FamilyActivitySelection = FamilyActivitySelection()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create SwiftUI view with initial selection
        let pickerView = FamilyActivityPickerView(initialSelection: initialSelection) { [weak self] selection in
            // Save selection and dismiss
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

    func setInitialSelection(_ selection: FamilyActivitySelection) {
        self.initialSelection = selection
    }

    func setOnSelection(_ callback: @escaping (FamilyActivitySelection) -> Void) {
        self.onSelection = callback
    }
}

@available(iOS 16.0, *)
struct FamilyActivityPickerView: View {
    @State private var selection: FamilyActivitySelection
    var onSelection: (FamilyActivitySelection) -> Void
    @Environment(\.presentationMode) var presentationMode

    init(initialSelection: FamilyActivitySelection = FamilyActivitySelection(), onSelection: @escaping (FamilyActivitySelection) -> Void) {
        _selection = State(initialValue: initialSelection)
        self.onSelection = onSelection
    }

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Save selection and notify parent
                            onSelection(selection)
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}
