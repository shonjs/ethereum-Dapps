pragma solidity ^0.4.23;

import "./IEthSwap.sol";


contract EthSwap is IEthSwap{

	// All the swaps
	mapping (bytes20 => Swap) public swaps;

	// State of a swap
	enum SwapState { Done, OneHand, TwoHands }
	
	// A Swap structure
	struct Swap {
		address firstParty;
		address secondParty;
		uint value;
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
		require (swaps[secretHash].swapState == SwapState.Done); 
		_; 
	}

	modifier canParticipate(bytes20 secretHash) { 
		require (swaps[secretHash].swapState == SwapState.OneHand); 
		_; 
	}
	

	function EthSwap () public {}

	function FirstPartyInitiate(
		address secondParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable
	canInitiate {
		swaps[secretHash].firstParty = msg.sender;
		swaps[secretHash].secondParty = secondParty;
		swaps[secretHash].value = msg.value;
		swaps[secretHash].startTime = block(this.block).timestamp;
		swaps[secretHash].deadLine = deadLine;
		swaps[secretHash].hashedSecret = hashedSecret;
		swaps[secretHash].swapState = SwapState.OneHand;

		FirstPartyInitiated(msg.sender, secondParty, deadLine);
	}

	function SecondPartyParticipate (
		address firstParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable
	canParticipate {
		swaps[secretHash].firstParty = firstParty;
		swaps[secretHash].secondParty = msg.sender;
		swaps[secretHash].value = msg.value;
		swaps[secretHash].startTime = block(this.block).timestamp;
		swaps[secretHash].deadLine = deadLine;
		swaps[secretHash].hashedSecret = hashedSecret;
		swaps[secretHash].swapState = SwapState.TwoHands;

		SecondPartyParticipated(firstParty, msg.sender, deadLine);
	}
	

}
