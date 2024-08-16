//
//  BaseResponseModel.swift
//  VNpay_Test
//
//  Created by pham kha dinh on 15/8/24.
//

import Foundation
struct ListResponseModel<T: Codable>: Codable {
    let data: [T]?
}
