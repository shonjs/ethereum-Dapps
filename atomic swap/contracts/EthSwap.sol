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
	event FirstPartyInitiated(address firstParty, bytes20 secretHash, uint deadLine);
	event SecondPartyParticipated(address secondParty, bytes20 secretHash, uint deadLine);
	event Swapped(address party, uint deadLine);
	event Refunded(address party, uint deadLine);

}
