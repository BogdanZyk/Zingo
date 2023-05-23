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
            .alert(Text("Error"),
                   isPresented: .init(get: {error != nil}, set: {state in
                if !state{
                    error = nil
                }
            }),
                   actions: {Button("OK", role: .cancel, action: {})},
                   message: {Text(error?.localizedDescription.prefix(100) ?? "")}
            )
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


