pragma solidity ^0.4.23;

interface IEthSwap {
	
	function FirstPartyInitiate(
		address secondParty,
		bytes20 hashedSecret,
		uint deadLine)
	external;

	function SecondPartyParticipate (
		address firstParty,
		bytes20 hashedSecret,
		uint deadLine)
	external;

	function Swap (
		bytes32 secret,
		bytes20 hashedSecret)
	external;

	function Refund (
		bytes20 hashedSecret)
	external;
}
