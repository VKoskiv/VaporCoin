//
//  Consensus.swift
//  App
//
//  Created by Valtteri Koskivuori on 10/01/2018.
//

import Foundation
import BigInt

let maxTransactionTimeDeviation: Double = 300 //5 minutes
let maxBlockTimeDeviation: Double = 1800 //30 minutes

//Maximum transactions per block
let maxTxnsPerBlock: Int = 6000

//Maximum time deviation for a block header/txn timestamp
let maxTimeDeviation: Int = 300 //5 minutes

//Minimum number of blocks before a coinbase transaction can be spent
let coinbaseMaturity: Int = 50

/*
In this file, funcs for verifying everything.
*/

//Consensus protocol extensions

extension Transaction {
	func currentBlockReward() -> Int64 {
		var fullAmount: Int64 = 5000000000
		
		//Figure out current block reward
		//Block reward is halved every 2 102 400 blocks
		
		let divCount: Int = state.blockDepth / 2_102_400
		
		for _ in 0..<divCount {
			fullAmount /= 2
		}
		
		return fullAmount
	}
}

//Transaction verification
extension Transaction {
	func verifyTransaction() -> Bool {
		//Check that output <= input
		//Check timestamp
		//Check addresses?
		return false
	}
}

//Block verification
extension Block {
	func verify() -> Bool {
		//Verify the validity of a block
		//Check that the reported hash matches
		let testHash = self.encoded.sha256
		if self.blockHash != testHash {
			print("Block hash doesn't match")
			return false
		}
		
		//Check that hash is valid (Matches difficulty)
		//FIXME: This is a bit of a hack
		if let hashNum = UInt256(data: NSData(data: self.blockHash)) {
			//HASH < 2^(256-minDifficulty) / currentDifficulty
			if hashNum > (UInt256.max - UInt256(32)) / UInt256(state.currentDifficulty) {
				//Block hash doesn't match current difficulty
				return false
			}
		}

		//This is the new BigInt implementation. Old UInt256 doesn't support / !
		/*let hashN = BigUInt(Data(from: self.blockHash))

		if hashN > BigUInt(2) ^ ( BigUInt(256) - BigUInt(32) ) / BigUInt(state.currentDifficulty) {
			//Block hash is greater than current difficulty requirement
			return false
		}*/
		
		//Check timestamp
		let currentTime: Double = Double(Date().timeIntervalSince1970)
		let maxTimeDeviation: Double = 1800 // 30 minutes
		if self.timestamp < (currentTime - maxTimeDeviation) {
			//Block timestamp more than 30min in past
			return false
		}
		if self.timestamp > (currentTime + maxTimeDeviation) {
			//Block timestamp more than 30min in future
			return false
		}
		
		//Looks good
		return true
	}

	var isValidDifficulty: Bool {
		let hashNum = BigUInt.init(Data(from: self.blockHash))

		if hashNum > BigUInt(2) ^ ( BigUInt(256) - BigUInt(32) ) / BigUInt(state.currentDifficulty) {
			//Block hash is greater than current difficulty requirement
			return false
		}
		//Difficulty is valid
		return true
	}
}
