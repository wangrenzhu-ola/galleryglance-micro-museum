import Foundation
import Observation
import StoreKit

enum PremiumAccessState: Equatable {
    case locked
    case loading
    case unlocked
    case error(String)

    var displayName: String {
        switch self {
        case .locked: "Locked"
        case .loading: "Checking"
        case .unlocked: "Unlocked"
        case .error: "Needs Attention"
        }
    }
}

@Observable
final class PremiumStore {
    private(set) var products: [Product] = []
    var accessState: PremiumAccessState = .locked
    var lastErrorMessage: String?

    let productIDs: Set<String> = [AppCopy.premiumProductID]

    var isUnlocked: Bool {
        accessState == .unlocked
    }

    var paywallSubtitle: String {
        if isUnlocked {
            "Premium themes are unlocked. Your free Eye Notes remain private and editable."
        } else {
            "Unlock optional visual themes for your saved Micro Museum. Today Gallery Card, Look Clue Challenge, and Eye Note Composer stay free."
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Array(productIDs))
            await refreshEntitlements()
            if products.isEmpty && !isUnlocked {
                setError("Premium themes are not available in this StoreKit environment. The free gallery ritual is still available.")
            }
        } catch {
            setError("Premium themes could not be loaded. The free gallery ritual is still available.")
        }
    }

    func purchasePremiumThemes(simulateFailure: Bool = false) async {
        if simulateFailure {
            setError("Purchase could not be completed. Your free gallery ritual is still available.")
            return
        }
        guard let product = products.first else {
            setError("Premium themes are not available right now. Continue with the free gallery ritual.")
            return
        }
        accessState = .loading
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                accessState = .unlocked
                lastErrorMessage = nil
            case .userCancelled:
                accessState = .locked
                lastErrorMessage = "Purchase cancelled. Your free gallery ritual is still available."
            case .pending:
                accessState = .locked
                lastErrorMessage = "Purchase is pending approval. You can keep using the free gallery ritual."
            @unknown default:
                setError("Purchase could not be completed. Your free gallery ritual is still available.")
            }
        } catch {
            setError("Purchase could not be completed. Your free gallery ritual is still available.")
        }
    }

    func restorePurchases() async {
        accessState = .loading
        await refreshEntitlements()
        if !isUnlocked {
            setError("No premium purchase was found to restore. The free gallery ritual is still available.")
        }
    }

    func unlockForTesting() {
        accessState = .unlocked
        lastErrorMessage = nil
    }

    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if productIDs.contains(transaction.productID) {
                accessState = .unlocked
                lastErrorMessage = nil
                return
            }
        }
        if accessState == .loading {
            accessState = .locked
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notAvailableInStorefront
        case .verified(let safe):
            return safe
        }
    }

    private func setError(_ message: String) {
        accessState = .error(message)
        lastErrorMessage = message
    }
}
