pragma solidity ^0.4.23;

/*
Interface for an onchain ethereum on chain atomic swap contract
*/

interface IEthSwap {
	
	function FirstPartyInitiate(
		address secondParty,
		bytes32 hashedSecret,
		uint deadLine)
	external payable;

	function SecondPartyParticipate (
		address firstParty,
		bytes32 hashedSecret,
		uint deadLine)
	external payable;

	function DoSwap (
		bytes secret,
		bytes32 hashedSecret)
	external;

	function Refund (
		bytes32 hashedSecret)
	external;
}
