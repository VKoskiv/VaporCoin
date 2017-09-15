//
//  Transaction.swift
//  VaporCoin
//
//  Created by Valtteri Koskivuori on 11/09/2017.
//

import Vapor
import Foundation
import Signature

class Address {
	
}

class Transaction: NSObject, NSCoding {
	
	//MARK: Class
	
	// 100,000,000 = 1.0 VaporCoins
	//Difference between inputAmt and outputAmt goes to miner as fee
	//TODO: Make sure output isn't greater than input
	var inputs: [Transaction]
	var outputs: [Transaction]
	var transactionAmount: Int64
	
	var transactionFee: Int64 {
		return 0
	}
	
	//From and senderpubkey are optional. BlockRewards don't need them.
	var from: Address? = nil
	var senderPubKey: CryptoKey? = nil //TODO: Keys and generation
	var senderSignature: ClientSignature
	
	var recipient: ClientSignature
	var txnHash: Data
	
	override init() {
		self.transactionAmount = 0
		self.inputs = []
		self.outputs = []
		self.from = Address()
		self.senderPubKey = try! CryptoKey(path: "", component: .publicKey)
		self.senderSignature = ClientSignature()
		
		self.recipient = ClientSignature()
		self.txnHash = Data()
	}
	
	init(inputs: [Transaction], outputs: [Transaction], transactionAmount: Int64, from: Address, senderPubKey: CryptoKey, senderSignature: ClientSignature, recipient: ClientSignature, hash: Data) {
		self.inputs = inputs
		self.outputs = outputs
		self.transactionAmount = transactionAmount
		self.from = from
		self.senderPubKey = senderPubKey
		self.senderSignature = senderSignature
		self.recipient = recipient
		self.txnHash = hash
	}
	
	func newTranscation(source: ClientSignature, dest: ClientSignature, input: Int64, output: Int64) -> Transaction {
		//TODO
		return Transaction()
	}
	
	func getInputs(forOwner: ClientSignature, forAmount: Int64) -> [Transaction] {
		//Get inputs
		//Then map filter out ones that have been spent
		//for tx in block.txns {
		//	  state.memPool = state.memPool.filter { $0 != tx}
		//}

		//Then take required amount starting from oldest
		
		//let allAvailableTransactions = state.blockChain.filter { $0.txns.filter { $0.outputs.filter { $0.recipient.address == forOwner.address } } }
		
		var allAvailableTransactions: [Transaction] = []
		
		//Get all past input transactions of the sender
		for block in state.blockChain {
			for txn in block.txns {
				if txn.recipient.address == forOwner.address {
					allAvailableTransactions.append(txn)
				}
			}
		}
		
		//Get all spent transactions
		/*for block in state.blockChain {
			for txn in block.txns {
				if txn.senderPubKey == forOwner.pubKey {
					
				}
			}
		}*/
		
		return [Transaction()]
	}
	
	func verify() -> Bool {
		//Check that output <= input
		//Check timestamp
		//Check addresses?
		return false
	}
	
	func encoded() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self)
	}
	
	//MARK: Swift encoding logic
	
	public convenience required init?(coder aDecoder: NSCoder) {
		let inputs = aDecoder.decodeObject(forKey: "inputs") as! [Transaction]
		let outputs = aDecoder.decodeObject(forKey: "outputs") as! [Transaction]
		let transactionAmount = aDecoder.decodeInt64(forKey: "transactionAmount")
		let from = aDecoder.decodeObject(forKey: "from") as! Address
		let senderPubKey = aDecoder.decodeObject(forKey: "senderPubKey") as! CryptoKey
		let senderSignature = aDecoder.decodeObject(forKey: "senderSignature") as! ClientSignature
		
		let recipient = aDecoder.decodeObject(forKey: "recipient") as! ClientSignature
		let hash = aDecoder.decodeObject(forKey: "hash") as! Data
		
		self.init(inputs: inputs, outputs: outputs, transactionAmount: transactionAmount, from: from, senderPubKey: senderPubKey, senderSignature: senderSignature, recipient: recipient, hash: hash)
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(inputs, forKey: "inputs")
		aCoder.encode(outputs, forKey: "outputs")
		aCoder.encode(transactionAmount, forKey: "transactionAmount")
		aCoder.encode(from, forKey: "from")
		aCoder.encode(senderPubKey, forKey: "senderPubKey")
		aCoder.encode(senderSignature, forKey: "senderSignature")
		aCoder.encode(recipient, forKey: "recipient")
	}
}
