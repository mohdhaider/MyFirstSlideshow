//
//  LRUCache.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

private class Node<T> {
    
    var content: T
    var prev: Node?
    var next: Node?
    
    init(_ val: T) {
        content = val
    }
}

private class DoublyLinkedList<T> {
    
    var count: Int = 0
    
    var head: Node<T>?
    var tail: Node<T>?
    
    func addToHead(_ node: Node<T>) {
        
        if head ==  nil {
            head = node
            tail = node
        }
        else {
            head?.prev = node
            node.next = head
            head = node
            head?.prev = nil
        }
        count += 1
    }
    
    func moveToHead(_ node: Node<T>) {
        
        if head === node {
            return
        }
        else if tail === node {
            
            _ = removeLast()
            
            addToHead(node)
        }
        else {
            let next = node.next
            let prev = node.prev
            
            prev?.next = next
            next?.prev = prev
            
            count -= 1
            
            addToHead(node)
        }
    }
    
    func removeLast() -> Node<T>? {
        
        guard let tailNode = tail else { return nil }
        
        let prev = tailNode.prev
        prev?.next = nil
        tail = prev
        
        count -= 1
        
        return tailNode
    }
}

enum LRUCacheType {
    case none
    case imageCache
}

final class LRUCache<Key, Value> where Key: Hashable {
    
    // MARK:- Variables -
    
    private struct NodeValue {
        var key: Key
        var value: Value
    }
    
    private var capicity: Int
    
    private var type:LRUCacheType = .none
    
    private var dictCached:[Key: Node<NodeValue>] = [Key: Node<NodeValue>]()
    
    private let dll = DoublyLinkedList<NodeValue>()
    
    // MARK:- Initializers -

    init(withCapicity capicity: Int, cacheType type: LRUCacheType) {
        self.capicity = capicity
        self.type = type
        prepareCache()
    }
    
    // MARK:- Class Helpers -
    
    func setValue(_ val: Value, forKey k: Key) {
        
        guard capicity > 0 else { return }
        
        if dll.count + 1 > capicity {
            if let lastNode = dll.tail {
                if !removeCachedData(forValue: lastNode.content.value) {
                    return
                }
            }
        }
        
        defer {
            if dll.count > capicity {
                
                if let last = dll.removeLast() {
                    
                    let key = last.content.key
                    dictCached.removeValue(forKey: key)
                }
            }
        }
        
        let value = NodeValue(key: k, value: val)
        
        guard let node = dictCached[k] else {
            
            let node = Node<NodeValue>(value)
            
            dll.addToHead(node)
            dictCached[k] = node
            
            return
        }
        
        node.content = value
        dll.moveToHead(node)
    }
    
    func getValue(forKey key: Key) -> Value? {

        guard capicity > 0 else { return nil }
        
        guard let node = dictCached[key] else {
            return nil
        }
        
        dll.moveToHead(node)
        
        return node.content.value
    }
}

extension LRUCache {
    
    private func prepareCache() {
        
        switch self.type {
        case .imageCache:
            createCacheForExistingImages()
        default:
            break
        }
    }
    
    private func createCacheForExistingImages() {
        
        if let allImages = try? FileManager.default.allCachedImageURLPaths() {
            
            for imageUrl in allImages {
                
                if let keyAvail = imageUrl.lastPathComponent as? Key,
                    let valueAvail = imageUrl as? Value {
                    setValue(valueAvail, forKey: keyAvail)
                }
            }
        }
    }
 
    private func removeCachedData(forValue value: Value) -> Bool {
        
        if let urlPath = value as? URL,
            urlPath.isFileURL {
            
            if !FileManager.default.fileExists(atPath: urlPath.absoluteString) {
                return true
            }
            else {
                do {
                    try FileManager.default.removeItem(at: urlPath)
                    return true
                }
                catch {
                    return false
                }
            }
        }
        return false
    }
}
