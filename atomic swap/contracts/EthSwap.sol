pragma solidity ^0.4.23;

import "./IEthSwap.sol";


contract EthSwap is IEthSwap{

	// All the swaps
	mapping (bytes20 => Swap) public swaps;

	// State of a swap
	enum SwapState { Usable, OneHand, TwoHands, NotUsable }
	
	// A Swap structure
	struct Swap {
		address firstParty;
		address secondParty;
		uint firstPartyValue;
		uint secondPartyValue;
		uint startTime;
		uint deadLine;
		bytes20 hashedSecret;
		bytes32 secret;
		SwapState swapState;		
	}

	// Events
	event FirstPartyInitiated(address firstParty, address secondParty, uint deadLine);
	event SecondPartyParticipated(address firstParty, address secondParty, uint deadLine);
	event Swapped(address party, uint deadLine);
	event Refunded(address party, uint deadLine);

	//Modifiers
	modifier canInitiate(bytes20 secretHash) { 
		require (swaps[secretHash].swapState == SwapState.Usable); 
		_; 
	}

	modifier canParticipate(bytes20 secretHash, address firstParty, address secondParty) { 
		require (swaps[secretHash].swapState == SwapState.OneHand);
		require (swaps[secretHash].firstParty == firstParty);
		require (swaps[secretHash].secondParty == secondParty);
		require (block(this.block).timestamp <= swaps[secretHash].deadLine);
		_; 
	}

	modifier canSwap(bytes32 secret, bytes20 secretHash) { 
		require (swaps[secretHash].swapState == SwapState.TwoHands);
		require (block(this.block).timestamp <= swaps[secretHash].deadLine);
		require (ripemd160(abi.encodePacked(secret)) == swaps[secretHash].hashedSecret);
		_; 
	}

	modifier canRefund(bytes20 secretHash) { 
		require (block(this.block).timestamp > swaps[secretHash].deadLine);
		_; 
	}
	

	constructor(EthSwap) public {}

	function FirstPartyInitiate(
		address secondParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable
	canInitiate(hashedSecret) {
		swaps[hashedSecret].firstParty = msg.sender;
		swaps[hashedSecret].secondParty = secondParty;
		swaps[hashedSecret].firstPartyValue = msg.value;
		swaps[hashedSecret].startTime = block(this.block).timestamp;
		swaps[hashedSecret].deadLine = deadLine;
		swaps[hashedSecret].hashedSecret = hashedSecret;
		swaps[hashedSecret].swapState = SwapState.OneHand;

		emit FirstPartyInitiated(msg.sender, secondParty, deadLine);
	}

	function SecondPartyParticipate (
		address firstParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable
	canParticipate(hashedSecret, firstParty, msg.sender) {
		swaps[hashedSecret].secondPartyValue = msg.value;
		swaps[hashedSecret].swapState = SwapState.TwoHands;

		emit SecondPartyParticipated(firstParty, msg.sender, deadLine);
	}
	
	function DoSwap (
		bytes32 secret,
		bytes20 hashedSecret)
	external
	canSwap(secret, hashedSecret) {
		swaps[hashedSecret].swapState = SwapState.NotUsable;
		if(msg.sender == swaps[hashedSecret].firstParty) {
			swaps[hashedSecret].secondPartyValue = 0;
			msg.sender.transfer(swaps[hashedSecret].secondPartyValue);
		} else 
		if(msg.sender == swaps[hashedSecret].secondParty) {
			swaps[hashedSecret].firstPartyValue =  0;
			msg.sender.transfer(swaps[hashedSecret].firstPartyValue);
		}
	}

	function Refund (
		bytes20 hashedSecret)
	external
	canRefund(hashedSecret) {
		if(msg.sender == swaps[hashedSecret].firstParty) {
			swaps[hashedSecret].firstPartyValue = 0;
			msg.sender.transfer(swaps[hashedSecret].firstPartyValue);
		} else 
		if(msg.sender == swaps[hashedSecret].secondParty) {
			swaps[hashedSecret].secondPartyValue =  0;
			msg.sender.transfer(swaps[hashedSecret].secondPartyValue);
		}
	}
}
