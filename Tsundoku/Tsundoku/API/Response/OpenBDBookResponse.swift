import Foundation

struct OpenBDBookResponse: Codable, Equatable {
    let title: String?
    let description: String?
    let author: [String]
    let publisher: String?
    let label: String?
    let publishingDate: Date?
    let isbn13: String?
    let thumbnailUrl: URL?
    let page: Int?
}

extension OpenBDBookResponse {
    init(_ json: Components.Schemas.OpenBDBook) {
        print("openBDBookResponse: \(json)")
        let title = json.summary?.title
        let publisher = json.summary?.publisher
        let publishingDate = json.summary?.pubdate.toDateFromYYYYMMDD
        let isbn13 = json.summary?.isbn
        let thumbnailUrl = URL(string: json.summary?.cover ?? "")

        let descriptionList = Set(json.onix?.collateral_detail?.text_content ?? [])
        let count = descriptionList.count
        let description: String? =
            switch count {
            case count where count > 1:
                // 説明が分かれている可能性があるので結合する
                descriptionList.compactMap(\.text).joined()
            case 1:
                descriptionList.first?.text
            default:
                nil
            }

        let descriptiveDetail = json.onix?.descriptive_detail
        let name = Set(descriptiveDetail?.contributor?.compactMap(\.person_name?.content) ?? [])
        let nameKana = Set(descriptiveDetail?.contributor?.compactMap(\.person_name?.collation_key) ?? [])
        let author = zip(name, nameKana).map { zipName, zipNameKana in
            nameKana.isEmpty ? zipName : "\(zipName) (\(zipNameKana))"
        }

        let labelList = Set(descriptiveDetail?.collection?.title_detail?.title_element?.compactMap(\.title_text?.content).filter({ !$0.isEmpty }) ?? [])
        let label: String? =
            switch labelList.count {
            case labelList.count where labelList.count > 1:
                labelList.joined(separator: OpenBDAPI.labelDelimiter)
            case 1:
                labelList.first
            default:
                nil
            }

        let page: Int? =
            if let extentValue = descriptiveDetail?.extent?.extent_value, let page = Int(extentValue) {
                page
            } else {
                nil
            }

        self.init(title: title, description: description, author: author, publisher: publisher, label: label, publishingDate: publishingDate, isbn13: isbn13, thumbnailUrl: thumbnailUrl, page: page)
    }
}
