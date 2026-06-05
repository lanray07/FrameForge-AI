import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionService: ObservableObject {
    @Published var products: [Product] = []
    @Published var activePlan: SubscriptionPlan = .free
    @Published var isLoading = false
    @Published var isRestoring = false
    @Published var errorMessage: String?

    private let productIDs = [
        "frameforge.pro.monthly",
        "frameforge.pro.yearly",
        "frameforge.agency.monthly"
    ]

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedProducts = try await Product.products(for: productIDs)
            products = loadedProducts.sorted { lhs, rhs in
                sortIndex(for: lhs.id) < sortIndex(for: rhs.id)
            }
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                updateActivePlan(for: transaction.productID)
                await transaction.finish()
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Unable to complete purchase. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var restoredPlan: SubscriptionPlan = .free

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.productID.contains("agency") {
                restoredPlan = .agencyPro
                break
            }

            if transaction.productID.contains("pro") {
                restoredPlan = .proCreator
            }
        }

        activePlan = restoredPlan
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func updateActivePlan(for productID: String) {
        activePlan = productID.contains("agency") ? .agencyPro : .proCreator
    }

    private func sortIndex(for productID: String) -> Int {
        productIDs.firstIndex(of: productID) ?? productIDs.count
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw NSError(
                domain: "FrameForgeAI.StoreKit",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "The transaction could not be verified."]
            )
        }
    }
}
