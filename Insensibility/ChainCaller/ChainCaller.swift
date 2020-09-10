//
//  ChainCaller.swift
//  ChainCaller
//
//  Created by 李宗良 on 2020/9/9.
//  Copyright © 2020 andrew. All rights reserved.
//
import Foundation

public typealias OpretionResult = (error: Error?, cancel: Bool, parameters: Any?)

fileprivate class ChainOperation {
    let queue: DispatchQueue
    init(queue: DispatchQueue) {
        self.queue = queue
    }
}

public typealias ChainSyncBlock = (_ parameter: OpretionResult) -> OpretionResult
fileprivate class ChainSyncOperation: ChainOperation {
    let block: ChainSyncBlock
    
    init(queue: DispatchQueue, block: @escaping ChainSyncBlock) {
        self.block = block
        super.init(queue: queue)
    }
}

public typealias ChainAsyncCompletion = (_ result: OpretionResult) -> Void
public typealias ChainAsyncBlock = (_ parameter: OpretionResult, _ completion: @escaping ChainAsyncCompletion) -> Void
fileprivate class ChainAsyncOperation: ChainOperation {
    let block: ChainAsyncBlock
    
    init(queue: DispatchQueue, block: @escaping ChainAsyncBlock) {
        self.block = block
        super.init(queue: queue)
    }
}

public typealias ChainResultBlock = (OpretionResult) -> Void
fileprivate class ChainResultOperation: ChainOperation {
    let block: ChainResultBlock
    
    init(queue: DispatchQueue, block: @escaping ChainResultBlock) {
        self.block = block
        super.init(queue: queue)
    }
}

fileprivate extension NSNotification.Name {
    static let ChainItemDone: NSNotification.Name = NSNotification.Name(rawValue: "com.chain.item.done")
}

public class ChainItem {
    
    private var operations: [ChainOperation] = []
    private var isSyncItem: Bool = true
    
    fileprivate var identifier: String
    fileprivate var queue: DispatchQueue = ChainItem.currentQueue()
    fileprivate var parameter: Any? = nil
    
    fileprivate init(identifier: String?, parameter: Any? = nil) {
        let hasID = (identifier?.count ?? 0) > 0
        
        self.identifier = hasID ? identifier! : "com.chain.item.\(UUID().uuidString.lowercased())"
        self.parameter = parameter
    }
    
    public func addProcess(syncBlock block: @escaping ChainSyncBlock) -> ChainItem {
        operations.append(ChainSyncOperation(queue: ChainItem.currentQueue(), block: block))
        return self;
    }
    
    public func addProcess(asyncBlock block: @escaping ChainAsyncBlock) -> ChainItem {
        isSyncItem = false
        operations.append(ChainAsyncOperation(queue: ChainItem.currentQueue(false), block: block))
        return self;
    }
    
    public func result(_ block: @escaping ChainResultBlock) -> Void {
        operations.append(ChainResultOperation(queue: ChainItem.currentQueue(), block: block))
        if isSyncItem {
            self.run()
        } else {
            queue = DispatchQueue(label: "com.chain.item.async")
            queue.async {
                self.run()
            }
        }
    }
    
    private class func currentQueue(_ isSync: Bool = true) -> DispatchQueue {
        var queue: DispatchQueue? = nil
        if isSync {
            if Thread.isMainThread {
                queue = DispatchQueue.main
            }
        }
        if queue == nil {
            if let currentQueue = OperationQueue.current?.underlyingQueue {
                queue = currentQueue
            } else {
                queue = DispatchQueue(label: "com.chain.item.async")
            }
        }
        return queue!
    }
    
    private func run() {
        var result: OpretionResult = (nil, false, parameter)
        let semaphore = DispatchSemaphore(value: 0)
        
        for ope in operations {
            let isSameQueue = isSyncItem ? true : queue.isEqual(ope.queue)
            
            if result.cancel {
                if let operation = operations.last as? ChainResultOperation {
                    if result.error == nil {
                        result.error = NSError(domain: "com.chain.item", code: -999, userInfo: [NSLocalizedDescriptionKey : "Canceled"])
                    }
                    result = (result.error, false, nil)
                    execuitResultOpretion(isSameQueue, operation, result)
                }
                sendDoneNotice()
                break
            }
            
            if let operation = ope as? ChainSyncOperation {
                if isSameQueue {
                    result = operation.block(result)
                } else {
                    weak var weakOpe = operation
                    operation.queue.async {
                        result = weakOpe!.block(result)
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
            } else if let operation = ope as? ChainAsyncOperation {
                weak var weakOpe = operation
                operation.queue.async {
                    weakOpe!.block(result) { value in
                        result = value
                        semaphore.signal()
                    }
                }
                semaphore.wait()
            } else if let operation = ope as? ChainResultOperation {
                execuitResultOpretion(isSameQueue, operation, result)
                sendDoneNotice()
                break
            }
        }
    }
    
    private func sendDoneNotice() -> Void {
        NotificationCenter.default.post(name: NSNotification.Name.ChainItemDone, object: self)
    }
    
    private func execuitResultOpretion(_ isSameQueue: Bool, _ operation: ChainResultOperation, _ result: OpretionResult) {
        if isSameQueue {
            operation.block(result)
        } else {
            weak var weakOpe = operation
            operation.queue.async {
                weakOpe!.block(result)
            }
        }
    }
}

public class ChainCaller {
    
    private var queues: [ChainItem] = []
    
    private static let instance = ChainCaller()
    
    private init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ChainItemDone, object: nil, queue: OperationQueue.main) { (notification) in
            if let target = notification.object as? ChainItem {
                self.queues.removeAll { (item) -> Bool in
                    return target.identifier == item.identifier
                }
            }
        }
    }
    
    public class func shared() -> ChainCaller {
        return ChainCaller.instance
    }
    
    public func startChain(identifier: String?, parameter: Any?) -> ChainItem {
        let item = ChainItem(identifier: identifier, parameter: parameter)
        queues.append(item)
        return item;
    }
}
