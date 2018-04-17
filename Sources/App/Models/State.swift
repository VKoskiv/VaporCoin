//
//  State.swift
//  Bits
//
//  Created by Valtteri Koskivuori on 12/09/2017.
//

import Foundation
import Vapor
import Transport
import Sockets

//Current client state
class State: Hashable {
	//Currently connected peers and their respective WS
	var peers: [PeerState: WebSocket]
	//Known hostnames
	var knownHosts: [String]
	
	//Pool of pending transactions to be processed
	var memPool: MemPool
	
	var blockChain: BlockChain
	
	var socketQueue: DispatchQueue
	
	var clientVersion = 1
	var clientType    = "hype-fullnode"
	
	//This is the wallet of this client. Only one for now.
	//Once we add wallet generation, we can add support for multiple Wallets.
	var wallet: Wallet? = nil

	var p2pProtocol: P2PProtocol
	var minerProtocol: MinerProtocol
	
	var outboundConnections: Int {
		return self.peers.count
	}
	
	let version: Int = 1
	
	//Move these to a consensus structure
	var currentDifficulty: Int64
	var blocksSinceDifficultyUpdate: Int
	
	init() {
		print("Initializing client state")
		self.peers = [:]
		
		self.knownHosts = []
		self.knownHosts.append("ws://192.168.1.101:8080/p2p")
		//self.knownHosts.append("proteus.vkoskiv.com")
		//self.knownHosts.append("triton.vkoskiv.com")
		
		self.memPool = MemPool()
		
		self.blockChain = BlockChain()
		
		print("GenesisBlockHash: \(blockChain.getLatestBlock().blockHash.hexString)")
		
		self.p2pProtocol = P2PProtocol()
		self.minerProtocol = MinerProtocol()
		
		self.socketQueue = DispatchQueue(label: "socks")
		
		//Blockchain state params
		self.currentDifficulty = 1
		self.blocksSinceDifficultyUpdate = 1
		
		self.wallet = Wallet(withKeyPath: "/Users/vkoskiv/coinkeys/")
		
		if let address = self.wallet?.readableAddress {
			print("Your address is: \(address)")
		}
		
		//self.initConnections()
		
		//Set up initial client conns
		/*DispatchQueue.global(qos: .background).async {
			self.initConnections()
			self.startSync()
		}*/
		
		//Start syncing on a background thread
		/*DispatchQueue.global(qos: .background).async {
			
		}*/
	}
	
	func startSync() {
		//Query other nodes for blockchain status, and then sync until latest block
		print("Starting background sync, from block \(state.blockChain.depth)")
		self.p2pProtocol.sendRequest(request: .getBlock, to: nil, 0)
	}
	
	//Get new peers AND get current network status (difficulty, block depth)
	func queryPeers() {
		//Query for new peers to add to list
		//TODO: A ping request to see if node is alive + versioning
		print("Querying for more hostnames from peers")
		for (p, _) in peers {
			//json = self.p2pProtocol.sendRequest(request: RequestType.getPeers, to: p, nil)
			//FIXME: Why can't we pass nil to the generic param??
			self.p2pProtocol.sendRequest(request: RequestType.getPeers, to: p, NSNull.self)
		}
	}
	
	//Outbound connections, this should be max 8 connections
	//Note, that these outbound connections are used *only* for outgoing messages.
	//All incoming ones are going thru the normal input socket
	func initConnections() {
		//Hard-coded, known nodes to start querying state from
		print("Initializing connections")
		for hostname in self.knownHosts {
			DispatchQueue.global(qos: .background).async {
				do {
					print("Connecting to \(hostname)...")
					try WebSocketFactory.shared.connect(to: hostname) { (websocket: WebSocket) throws -> Void in
						print("Connected to \(hostname)")
						//Connected
						//TODO: WebSocket pinging and stuff
						//Here we query the client for clientVersion, type...
						
						websocket.onText = { ws, text in
							let json = try JSON(bytes: text.makeBytes())
							print(json)
						}
						
						/*let newPeer = PeerState(hostname: hostname, clientVersion: 1, clientType: "eee")
						state.peers.updateValue(websocket, forKey: newPeer)*/
					}
				} catch {
					print("Failed to connect to \(hostname), error: \(error)")
				}
			}
			
		}
		//queryPeers()
	}
	
	var hashValue: Int {
		//TODO: Get a unique hashvalue
		return self.version
	}
	
	func updateDifficulty() {
		//Look at how long last 60 blocks took, and update difficulty
		let startTime = self.blockChain.getBlockWith(index: self.blockChain.depth - 60).timestamp
		let timeDiff = self.blockChain.getLatestBlock().timestamp - startTime
		print("Last 60 blocks took \(timeDiff)s, target is 3600s")
		//Target is 3600s (1 hour)
		print("Difficulty before: \(self.currentDifficulty)")
		self.currentDifficulty *= Int64(3600 / timeDiff)
		print("Difficulty after:  \(self.currentDifficulty)")
		self.blocksSinceDifficultyUpdate = 0
	}
	
}

func ==(lhs: State, rhs: State) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
