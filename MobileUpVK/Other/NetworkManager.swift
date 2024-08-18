//
//  Project name: MobileUpVK
//  File name: NetworkManager.swift
//
//  Copyright © Gromov V.O., 2024
//

import Foundation
import UIKit


class NetworkManager {
   
    // MARK: - Singleton
    static let shared = NetworkManager()
    private init() {}
    
    // MARK: - https://dev.vk.com/ru/method/groups.getById

    func getVKGroupID(withName name: String, token: String, completion: @escaping (Result<Int, Error>) -> Void) {
                
        var baseUrl = URLComponents(string: "https://api.vk.com/method/groups.getById")!
                baseUrl.queryItems = [
                    URLQueryItem(name: "group_id", value: name),
                    URLQueryItem(name: "access_token", value: token),
                    URLQueryItem(name: "v", value: "5.199"),
                ]
        
        guard let url = baseUrl.url else {
            completion(.failure(MobileUpProjectError.invalidURL("func getVKGroupID")))
            return
        }
    
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(MobileUpProjectError.noDataReceived("func getVKGroupID")))
                return
            }

            do {
                let group = try JSONDecoder().decode(VKGroupJSONModel.self, from: data).response.groups.first
                guard let id = group?.id else {
                    completion(.failure(MobileUpProjectError.decoderError("func getVKGroupID")))
                    return
                }
                completion(.success(id))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - https://dev.vk.com/ru/method/photos.getAll
    func getVKGroupPhotoURLs(withToken token: String, forID id: Int, completion: @escaping (Result<[VKPhotoItem], Error>) -> Void) {
        
        var baseUrl = URLComponents(string: "https://api.vk.com/method/photos.getAll")!
        baseUrl.queryItems = [
            URLQueryItem(name: "owner_id", value: "-\(id)"),
            URLQueryItem(name: "no_service_albums", value: "1"),
            URLQueryItem(name: "skip_hidden", value: "1"),
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "v", value: "5.199"),
        ]
        
        guard let url = baseUrl.url else {
            completion(.failure(MobileUpProjectError.invalidURL("func getVKGroupPhotoURLs")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, resp, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(MobileUpProjectError.noDataReceived("func getVKGroupPhotoURLs")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(VKGroupPhotoJSONModel.self, from: data).response.items
                completion(.success(response))
            } catch {
                completion(.failure(MobileUpProjectError.decoderError("func getVKGroupPhotoURLs")))
            }
        }
        task.resume()
    }

    // MARK: - https://dev.vk.com/ru/method/video.get
    func getVKGroupVideo(withToken token: String, forID id: Int, completion: @escaping (Result<[VKVideoItem], Error>) -> Void) {
        
        var baseUrl = URLComponents(string: "https://api.vk.com/method/video.get")!
        baseUrl.queryItems = [
            URLQueryItem(name: "owner_id", value: "-\(id)"),
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "v", value: "5.199"),
        ]
        
        guard let url = baseUrl.url else {
            completion(.failure(MobileUpProjectError.invalidURL("func getVKGroupVideo")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, resp, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else {
                completion(.failure(MobileUpProjectError.noDataReceived("func getVKGroupVideo")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(VKGroupVideoJSONModel.self, from: data).response.items
                completion(.success(response))
            } catch (let error){
                print(error)
                completion(.failure(MobileUpProjectError.decoderError("func getVKGroupVideo")))
            }
        }
        
        task.resume()
        
        
        
    }
    
    // MARK: - Image downloader

    func stringURLToUIImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(MobileUpProjectError.invalidURL("func stringURLToUIImage")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, resp, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else {
                completion(.failure(MobileUpProjectError.noDataReceived("func stringURLToUIImage")))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(MobileUpProjectError.imageError("func stringURLToUIImage")))
                return
            }
            
            completion(.success(image))
        }
        
        task.resume()
    }
    
}

