//
//  FBListenerResult.swift
//  Zingo
//
//  Created by Bogdan Zykov on 07.07.2023.
//

import Combine
import FirebaseFirestore


struct FBListenerResult<T: Decodable>{
    
    let publisher: AnyPublisher<[T], Error>
    let listener: ListenerRegistration
    
}
