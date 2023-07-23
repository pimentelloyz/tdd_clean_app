import XCTest
import Domain
import Data

final class RemoteAddAccountTests: XCTestCase {

    func test_add_shouldCallHttpClientWithCorrectUrl() throws {
        let url = try XCTUnwrap(URL(string: "http://any-url.com"))
        let (sut, httpClient) = makeSUT(url: url)
        sut.add(addAccountModel: makeAddAccountModel())
        
        XCTAssertEqual(httpClient.requestUrls, [url])
    }
    
    func test_add_shouldCallHttpClientWithCorrectData() throws {
        let (sut, httpClient) = makeSUT()
        
        let addAccountModel = makeAddAccountModel()
        sut.add(addAccountModel: addAccountModel)
        
        XCTAssertEqual(httpClient.data, addAccountModel.toData())
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
        
        func post(to url: URL, with data: Data?) {
            self.requestUrls.append(url)
            self.data = data
        }
    }
}
