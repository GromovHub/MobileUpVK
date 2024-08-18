//
//  Project name: MobileUpVK
//  File name: JSONModels.swift
//
//  Copyright © Gromov V.O., 2024
//

//only required fields

// MARK: - group info json

struct VKGroupJSONModel: Codable {
    let response: VKGroupResponse
}
struct VKGroupResponse: Codable {
    let groups: [VKGroup]
}
struct VKGroup: Codable {
    let id: Int
}

// MARK: - group photo json

struct VKGroupPhotoJSONModel: Codable {
    let response: VKGroupPhotoResponse
}
struct VKGroupPhotoResponse: Codable {
    let count: Int
    let items: [VKPhotoItem]
}

struct VKPhotoItem: Codable {
    let text: String
    let date: Int
    let origPhoto: VKPhotoItemOrig
    
    enum CodingKeys: String, CodingKey {
        case origPhoto = "orig_photo"
        case text, date
    }
}
struct VKPhotoItemOrig: Codable {
    let url: String
}

// MARK: - group video json

struct VKGroupVideoJSONModel: Codable {
    let response: VKGroupVideoResponse
}
struct VKGroupVideoResponse: Codable {
    let count: Int
    let items: [VKVideoItem]
}
struct VKVideoItem: Codable {
    let description, title, player: String
    let image: [VKVideoPreviewImage]
}
struct VKVideoPreviewImage: Codable {
    let url: String
    let width, height: Int
}
