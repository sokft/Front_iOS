//
//  TokenProvider.swift
//  ttakkeun
//
//  Created by 정의찬 on 7/9/24.
//

import Foundation
import Moya

class TokenProvider: TokenProviding {
    
    
    private let userSession = "userSession"
    private let keyChain = KeyChainManager.standard
    private let provider = MoyaProvider<AuthAPITarget>()
    
    var accessToken: String? {
        get {
            guard let userInfo = keyChain.loadSession(for: userSession) else { return nil }
            return userInfo.accessToken
        }
        
        set {
            guard var userInfo = keyChain.loadSession(for: userSession) else { return }
            userInfo.accessToken = newValue
            if keyChain.saveSession(userInfo, for: "userSession") {
                print("유저 토큰 갱신 됨")
            }
        }
    }
    
    /* 리프레시 토큰 데이터 담아서 보내야 함 */
    func refreshToken(completion: @escaping (String?, Error?) -> Void) {
        guard let userInfo = keyChain.loadSession(for: "userSession"), let refreshToken = userInfo.refreshToken else { return }
        
        provider.request(.refreshToken(refreshToken: refreshToken)) { result in
            switch result {
            case .success(let response):
                do {
                    let tokenData = try JSONDecoder().decode(TokenResponse.self, from: response.data)
                    self.accessToken = tokenData.result.accessToken
                    completion(self.accessToken, nil)
                } catch {
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}
