//
//  State.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Signature
import Vapor

class PeerState {
	//Only store what we need to know of a peer
	
}

//Current client state
class State: Hashable {
	//Connections to other clients
	//Hostname: Peer
	var peers: [String: PeerState]
	//Pool of pending transactions to be processed
	var memPool: [Transaction]
	
	//For now, just a in-memory array.
	//Eventually have an in-memory queue of an array of arrays of blocks
	//And then only store to DB when we TRUST a  block
	var blockChain: [Block]
	
	var signature: ClientSignature? = nil

	var p2pProtocol: P2PProtocol
	var minerProtocol: MinerProtocol
	
	var currentDifficulty: Int64
	var blocksSinceDifficultyUpdate: Int
	
	init() {
		print("Initializing client state")
		self.peers = [:]
		self.memPool = []
		self.blockChain = []
		self.blockChain.append(genesisBlock())
		self.p2pProtocol = P2PProtocol()
		self.minerProtocol = MinerProtocol()
		self.currentDifficulty = 1
		self.blocksSinceDifficultyUpdate = 1
		
		var pubKey: CryptoKey
		var privKey: CryptoKey
		do {
			print("Loading crypto keys")
			pubKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/public.pem", component: .publicKey)
			privKey = try CryptoKey(path: "/Users/vkoskiv/coinkeys/private.pem", component: .privateKey(passphrase:nil))
			
			self.signature = ClientSignature(pub: pubKey, priv: privKey)
		} catch {
			print("Crypto keys not found!")
		}
	}
	
	var hashValue: Int {
		return self.hashValue
	}
	
	func peerForHostname(host: String) -> PeerState {
		//return (self.peers.filter { $0.key.hostname == host }.first?.key)!
		return self.peers[host]!
	}
	
	//MARK: Interact with blockchain
	func getBlockWithHash(hash: Data) -> Block {
		let blocks = self.blockChain.filter { $0.blockHash == hash }
		if blocks.count > 1 {
			print("Found more than 1 block with this hash. Yer blockchain's fucked.")
			return Block()
		}
		return blocks.first!
	}
	
	func getLatestBlock() -> Block {
		return self.blockChain.last!
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
