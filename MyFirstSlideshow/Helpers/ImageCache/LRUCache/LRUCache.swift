//
//  LRUCache.swift
//  MyFirstSlideshow
//
//  Created by Mohd Haider on 26/05/19.
//  Copyright © 2019 Yoti. All rights reserved.
//

import Foundation

/// Doubly linked list node for referecing next and previous node.
private class Node<T> {
    
    var content: T
    var prev: Node?
    var next: Node?
    
    init(_ val: T) {
        content = val
    }
}

/// Doubly linked list class to provide LRU cache feature
private class DoublyLinkedList<T> {
    
    var count: Int = 0
    
    var head: Node<T>?
    var tail: Node<T>?
    
    /// Add node to head and change haad to new node
    ///
    /// - Parameter node: Node
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
    
    /// Send node to head and change head to new moved node
    ///
    /// - Parameter node: Node
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
    
    /// Remove last node
    ///
    /// - Returns: Deleted node
    func removeLast() -> Node<T>? {
        
        guard let tailNode = tail else { return nil }
        
        let prev = tailNode.prev
        prev?.next = nil
        tail = prev
        
        count -= 1
        
        return tailNode
    }
    
    /// Remove input node. Node can at head, tail or in middle.
    /// Removing node accordingly
    /// - Parameter node: Node
    func removeNode(_ node: Node<T>) {
        
        guard let tailNode = tail else { return }
        
        if tailNode === node{

            let prev = tailNode.prev
            prev?.next = nil
            tail = prev
            
            if node === head {
                count = 0
                head?.next = nil
                head = nil
            }
        } else if node === head {
            
            let next = node.next
            head?.next = nil
            next?.prev = nil
            head = next
            
            count -= 1
        } else {
            let next = node.next
            let prev = node.prev
            
            prev?.next = next
            next?.prev = prev
            
            count -= 1
        }
    }
    
    /// Deleting all nodes when requires
    func deleteAllNodes() {

        while tail != nil {
            _ = removeLast()
        }
        count = 0
        head?.next = nil
        head = nil
    }
}

/// Cache type to provide specific functionality
///
/// - none: No type described
/// - imageCache: Image LRU cache
enum LRUCacheType {
    case none
    case imageCache
}

/// LRU singleton class
final class LRUCache<Key, Value> where Key: Hashable {
    
    // MARK:- Variables -
    
    private struct NodeValue {
        var key: Key
        var value: Value
    }
    
    private var capicity: Int
    
    private var type:LRUCacheType = .none
    
    /// Every operation in LRU cache is a write operation.
    /// If we accessig a element, then moving it to front and if we saving a element.
    /// Then we also making a write operation. So we do need to make it serialize for
    /// thread safety.
    private let dictCachedSerialQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.dictCached")
    private var tempDictCached:[Key: Node<NodeValue>] = [Key: Node<NodeValue>]()
    private var dictCached:[Key: Node<NodeValue>] {
        get {
            return dictCachedSerialQueue.sync { tempDictCached }
        }
        set {
            dictCachedSerialQueue.async {[weak self] in self?.tempDictCached = newValue }
        }
    }
    
    private let dllSerialQueue:DispatchQueue = DispatchQueue(label: "com.Yoti.DoublyLinkedList")
    private var tempDll = DoublyLinkedList<NodeValue>()
    private var dll:DoublyLinkedList<NodeValue> {
        get {
            return dllSerialQueue.sync { tempDll }
        }
        set {
            dllSerialQueue.async {[weak self] in self?.tempDll = newValue }
        }
    }
    
    // MARK:- Initializers -

    init(withCapicity capicity: Int, cacheType type: LRUCacheType) {
        self.capicity = capicity
        self.type = type
        prepareCache()
    }
    
    // MARK:- Class Helpers -
    
    /// Set generic values to LRU cache
    ///
    /// - Parameters:
    ///   - val: Value to store for key
    ///   - k: Key to handle value
    /// - Returns: Operation success
    func setValue(_ val: Value, forKey k: Key) -> Bool {
        
        guard capicity > 0 else { return false }
        
        if dll.count + 1 > capicity {
            if let lastNode = dll.tail {
                if !removeCachedData(forValue: lastNode.content.value) {
                    return false
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
            
            return true
        }
        
        node.content = value
        dll.moveToHead(node)
        
        return true
    }
    
    /// Get value from LRU cache for input key
    ///
    /// - Parameter key: inout jey
    /// - Returns: desired value if found
    func getValue(forKey key: Key) -> Value? {

        guard capicity > 0 else { return nil }
        
        guard let node = dictCached[key] else {
            return nil
        }
        
        dll.moveToHead(node)
        
        return node.content.value
    }
    
    /// Delete a value for input key
    ///
    /// - Parameter key: input key
    func removeValue(forKey key: Key) {
        
        guard capicity > 0 else { return }
        
        guard let node = dictCached[key] else {
            return
        }
        
        dll.removeNode(node)
        _ = removeCachedData(forValue: node.content.value)
    }
    
    /// Clear all cached data on requirement. As disk become full
    func clearLRUCache() {
        
        dll.deleteAllNodes()
        dictCached.removeAll()
    }
}

extension LRUCache {
    
    /// prepare cache for specific cache type
    private func prepareCache() {
        
        switch self.type {
        case .imageCache:
            createCacheForExistingImages()
        default:
            break
        }
    }
    
    /// Fetch all existing image for File storage and prepare LRU cache for that
    /// If our LRU cache capicity is exceeding, then we will remove files
    /// from local.
    private func createCacheForExistingImages() {
        
        if let allImages = try? FileManager.default.allCachedImageURLPaths() {
            
            for imageUrl in allImages {
                
                if let keyAvail = imageUrl.lastPathComponent as? Key,
                    let valueAvail = imageUrl as? Value {
                    if !setValue(valueAvail, forKey: keyAvail) {
                        _ = removeCachedData(forValue: valueAvail)
                    }
                }
            }
        }
    }
 
    /// Remove cached data from file storage
    ///
    /// - Parameter value: URL for removing data from file storage
    /// - Returns: Completion success
    private func removeCachedData(forValue value: Value) -> Bool {
        
        if let url = value as? URL,
            url.isFileURL {
            
            if !FileManager.default.fileExists(atPath: url.path) {
                return true
            }
            else {
                do {
                    try FileManager.default.removeItem(at: url)
                    return true
                } catch {
                    return false
                }
            }
        }
        return false
    }
}
