//
//  DataEx.swift
//  VNpay_Test
//
//  Created by pham kha dinh on 15/8/24.
//

import Foundation
extension Data {
    func decoded<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: self)
            return object
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
    func arrayDecoded<T: Decodable>() -> [T]? {
        let decoder = JSONDecoder()
        do {
            let array = try decoder.decode([T].self, from: self)
            return array
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}
