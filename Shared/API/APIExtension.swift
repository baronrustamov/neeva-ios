// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

extension SuggestionsQuery.Data.Suggest.QuerySuggestion.Annotation {
    public func isChangeInStockPricePositive() -> Bool {
        return stockInfo?.changeFromPreviousClose ?? 0.0 > 0
    }

    public func dictionarySupplementText() -> String {
        var supplementText = ""
        if let phoneticSpelling = dictionaryInfo?.phoneticSpelling {
            supplementText += "| \(phoneticSpelling) "
        }
        if let lexicalCategory = dictionaryInfo?.lexicalCategory {
            supplementText += "| \(lexicalCategory) "
        }
        return supplementText
    }
}
