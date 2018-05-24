pragma solidity ^0.4.23;

/*
Interface for an onchain ethereum on chain atomic swap contract
*/

interface IEthSwap {

	modifier isRefundAllowed(uint _time);
	
	function FirstPartyInitiate(
		address secondParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable;

	function SecondPartyParticipate (
		address firstParty,
		bytes20 hashedSecret,
		uint deadLine)
	external payable;

	function Swap (
		bytes32 secret,
		bytes20 hashedSecret)
	external;

	function Refund (
		bytes20 hashedSecret)
	external;
}
