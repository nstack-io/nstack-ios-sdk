//
//  Country.swift
//  NStack
//
//  Created by Chris on 27/10/2016.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public struct Country: Codable {
    public let id: Int
	public let name: String
	public let code: String
	public let codeIso: String
	public let native: String
    public let phone: Int?
	public let continent: String
	public let capital: String?
    public let capitalLat: Double?
	public let capitalLng: Double?
	public let currency: String
	public let currencyName: String
	public let languages: String?
	public let image: URL?
	public let imagePath2: URL?
    public let capitalTimeZone: Timezone?

    enum CodingKeys: String, CodingKey {
        case id, name, code, codeIso, native, phone, continent
        case capital, capitalLat, capitalLng, currency, currencyName
        case languages, image, capitalTimeZone
        case imagePath2 = "image_path_2"
    }
}
