import Foundation

public struct EpicFreeGames: Codable {
    public let data: ResponseData

    public struct ResponseData: Codable {
        public enum CodingKeys: String, CodingKey {
            case catalog = "Catalog"
        }

        public let catalog: Catalog

        public struct Catalog: Codable {
            public let searchStore: SearchStore

            public struct SearchStore: Codable {
                public let elements: [Element]

                public struct Element: Codable {
                    public let title: String
                    public let id: String?
                    public let namespace: String?
                    public let description: String?
                    public let keyImages: [KeyImage]?
                    public let seller: Seller?
                    public let productSlug: String?
                    public let urlSlug: String?
                    public let customAttributes: [CustomAttribute]?
                    public let price: Price?
                    public let promotions: Promotions?

                    public struct KeyImage: Codable {
                        public let type: String
                        public let url: URL
                    }

                    public struct Seller: Codable {
                        public let id: String
                        public let name: String
                    }

                    public struct CustomAttribute: Codable {
                        public let key: String?
                        public let value: String?
                    }

                    public struct Price: Codable {
                        public let totalPrice: TotalPrice?

                        public struct TotalPrice: Codable {
                            public let discountPrice: Int?
                            public let originalPrice: Int?
                            public let currencyCode: String?
                            public let currencyInfo: CurrencyInfo?
                            public let fmtPrice: FmtPrice?

                            public struct CurrencyInfo: Codable {
                                public let decimals: Int?
                            }

                            public struct FmtPrice: Codable {
                                public let originalPrice: String?
                                public let discountPrice: String?
                                public let intermediatePrice: String?
                            }
                        }
                    }

                    public struct Promotions: Codable {
                        public let promotionalOffers: [Promotion]
                        public let upcomingPromotionalOffers: [Promotion]

                        public struct Promotion: Codable {
                            public let promotionalOffers: [Offer]

                            public struct Offer: Codable {
                                public let startDate: Date
                                public let endDate: Date
                                public let discountSetting: DiscountSetting

                                public struct DiscountSetting: Codable, CustomStringConvertible {
                                    public let discountType: String
                                    public let discountPercentage: Int?

                                    public var description: String {
                                        if discountType == "PERCENTAGE" {
                                            return discountPercentage == 0 ? "Free" : "\(discountPercentage.map(String.init) ?? "?") %"
                                        } else {
                                            return "?"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}