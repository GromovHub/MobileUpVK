//
//  Project name: MobileUpVK
//  File name: TokenManager.swift
//
//  Copyright © Gromov V.O., 2024
//


import Foundation

struct TokenInfo: Codable {
    let token: String
    let expirationDate: Date
}

// MARK: - save, get, check expiration, clean token


class TokenManager {
    
    private static let tokenKey = Strings.tokenKey
    private static let userDefaults = UserDefaults.standard
    
    static func saveToken(token: String, expiresIn: Int) {
        let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        let tokenInfo = TokenInfo(token: token, expirationDate: expirationDate)
        
        if let encoded = try? JSONEncoder().encode(tokenInfo) {
            userDefaults.set(encoded, forKey: tokenKey)
        }
    }
    
    static func getStoredToken() -> TokenInfo? {
        guard let data = userDefaults.data(forKey: tokenKey),
              let tokenInfo = try? JSONDecoder().decode(TokenInfo.self, from: data) else {
            return nil
        }
        return tokenInfo
    }
    
    static func isTokenValid() -> Bool {
        guard let tokenInfo = getStoredToken() else {
            print(MobileUpProjectError.restoreTokenError("check Token Manager"))
            return false
        }
        // 5 min
        let isValid = tokenInfo.expirationDate.timeIntervalSinceNow > 300
        return isValid
    }
    
    static func clearToken() {
        userDefaults.set(Data(), forKey: tokenKey)
    }
}
