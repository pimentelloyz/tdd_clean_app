import Foundation
import Domain

public final class RemoteAddAccount {
    private let url: URL
    private let httpPostClient: HttpPostClient
    
    public init(url: URL, httpPostClient: HttpPostClient) {
        self.url = url
        self.httpPostClient = httpPostClient
    }
    
    public func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, DomainError>) -> Void) {
        httpPostClient.post(to: url, with: addAccountModel.toData()) { result in
            switch result {
            case .success(let data):
                if let accountModel: AccountModel = data.toModel() {
                    completion(.success(accountModel))
                }
            case .failure: completion(.failure(.unexpected))
            }
        }
    }
}
