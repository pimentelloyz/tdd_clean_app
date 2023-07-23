import XCTest
import Domain
import Data

final class RemoteAddAccountTests: XCTestCase {

    func test_add_shouldCallHttpClientWithCorrectUrl() throws {
        let url = try XCTUnwrap(URL(string: "http://any-url.com"))
        let (sut, httpClient) = makeSUT(url: url)
        sut.add(addAccountModel: makeAddAccountModel()) { _ in }
        
        XCTAssertEqual(httpClient.requestUrls, [url])
    }
    
    func test_add_shouldCallHttpClientWithCorrectData() throws {
        let (sut, httpClient) = makeSUT()
        
        let addAccountModel = makeAddAccountModel()
        sut.add(addAccountModel: addAccountModel) { _ in }
        
        XCTAssertEqual(httpClient.data, addAccountModel.toData())
    }
    
    func test_add_shouldCompletesWithErrorIfClientCompletesWithError() throws {
        let (sut, httpClient) = makeSUT()
        
        let exp = expectation(description: "waiting")
        sut.add(addAccountModel: makeAddAccountModel()) { result in
            switch result {
            case .success: XCTFail("Não deveria cair aqui, foi erro do dev: o esperado era um erro e o recebido foi \(result)")
            case .failure(let error): XCTAssertEqual(error, .unexpected)
            }
            exp.fulfill()
        }
        
        httpClient.completionWithError(.noConnectivity)
        wait(for: [exp], timeout: 1)
    }
}

extension RemoteAddAccountTests {
    
    func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteAddAccount, httpClient: HttpPostClientSpy) {
        let httpClient = HttpPostClientSpy()
        let sut = RemoteAddAccount(url: url, httpPostClient: httpClient)
        
        return (sut, httpClient)
    }
    
    func makeAddAccountModel() -> AddAccountModel {
        return AddAccountModel(name: "Any Name", email: "any-email@mail.com", password: "1234", passwordConfirmation: "1234")
    }
    
    class HttpPostClientSpy: HttpPostClient {
        var requestUrls: [URL] = []
        var data: Data?
        var completion: ((Result<Data, HttpError>) -> Void)?
        
        func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HttpError>) -> Void) {
            self.requestUrls.append(url)
            self.data = data
            self.completion = completion
        }
        
        func completionWithError(_ error: HttpError) {
            completion?(.failure(error))
        }
    }
}
