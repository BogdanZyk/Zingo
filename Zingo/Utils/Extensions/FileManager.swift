//
//  FileManager.swift
//  Zingo
//
//  Created by Bogdan Zykov on 06.06.2023.
//

import Foundation

extension FileManager{
    
    
    func createImagePath(with id: String) -> URL?{
        guard let url = self.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).jpg") else { return nil}
        return url
    }
    
    func createVideoPath(with name: String) -> URL?{
        guard let url = self.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(name) else { return nil}
        return url
    }

    func removeFileExists(for url: URL){
        if fileExists(atPath: url.path){
            do{
                try removeItem(at: url)
            }catch{
                print("Error to remove item", error.localizedDescription)
            }
        }
    }
}
