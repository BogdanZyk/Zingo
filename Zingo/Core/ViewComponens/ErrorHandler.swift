//
//  ErrorHandler.swift
//  Zingo
//
//  Created by Bogdan Zykov on 22.05.2023.
//

import SwiftUI

public struct ErrorHandleModifier: ViewModifier {
    @Binding var error: Error?

    public func body(content: Content) -> some View {
        content
        // Avoid SwiftUI Bug's for alert is not shown.
            .background(EmptyView().alert(item: .init(get: {
                error.map(Identity.init)
            }, set: { identifiableError in
                error = identifiableError?.error
            }), content: { identifiableError in
                Alert(
                    title: Text("Error"),
                    message: Text(identifiableError.localizedDescription.prefix(100)),
                    dismissButton: .default(Text("OK"))
                )
            }))
    }
}

extension View {
    public func handle(error: Binding<Error?>) -> some View {
        modifier(ErrorHandleModifier(error: error))
    }
}


struct Identity<T>: Identifiable {
    let id = UUID()
    let value: T

    init(_ value: T) {
        self.value = value
    }
}

extension Identity: Error, LocalizedError where T: Error {
    var error: Error { value }

    var errorDescription: String? {
        error.localizedDescription
    }
    // TODO:
    var failureReason: String? { nil }
    var recoverySuggestion: String? { nil }
    var helpAnchor: String? { nil }
}
