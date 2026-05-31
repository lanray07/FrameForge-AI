import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionService: ObservableObject {
    @Published var products: [Product] = []
    @Published var activePlan: SubscriptionPlan = .free
    @Published var isLoading = false
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
            products = try await Product.products(for: productIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                activePlan = transaction.productID.contains("agency") ? .agencyPro : .proCreator
                await transaction.finish()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
