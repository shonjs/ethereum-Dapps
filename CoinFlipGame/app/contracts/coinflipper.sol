	pragma solidity ^0.4.19;
	contract coinFlipper{
		mapping(uint=>address) parties;
		uint bet;
		string public latestResultHash;
		uint[] private variables = new uint[](2);
		address private winner;

		enum GameState { betOpen, betWaiting, betClosed}
		GameState public coinFlip;

		event GameResult(address winner, uint winnings);		

		function coinFlipper() public{
			coinFlip = GameState.betOpen;
		}

		modifier gameOn(GameState _state){
			require(coinFlip == _state);
			_;
		}

		function offerBet(uint _rand) public payable 
		gameOn(GameState.betOpen) {		
			bet = msg.value;
			coinFlip = GameState.betWaiting;
			parties[0] = msg.sender;
			variables[0] = _rand;
		}

		function meetBet(uint _rand) public payable 
		gameOn(GameState.betWaiting){
			require(msg.value >= bet);
			coinFlip = GameState.betClosed;
			parties[1] = msg.sender;
			variables[1] = _rand;
		}

		function flipCoin() public 
		gameOn(GameState.betClosed){			
			uint winnings = this.balance;
			if(((variables[0] * block.number) + (variables[1] * block.timestamp))% 2 == 0){
				parties[0].transfer(this.balance);
				winner = parties[0];
			} else {
				parties[1].transfer(this.balance);
				winner = parties[1];
			}
			GameResult(winner, winnings);
			coinFlip = GameState.betOpen;
		}

		function setResult(string storageHash) public
		gameOn(GameState.betClosed){
			require(winner == msg.sender);
			latestResultHash = storageHash;
		}
	}