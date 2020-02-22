require('dotenv');
var Web3 = require('web3');
var provider = new Web3.providers.HttpProvider(process.env.PROVIDER_LOCAL);
var web3 = new Web3(provider);
var accounts = web3.eth.getAccounts()
				.then((accounts)=>{
					var defaultAccount = accounts[0];
					var party1 = accounts[1];
					var party2 = accounts[2];
var currentState = async ()=>{await coinFlipper.coinFlip.call({from:defaultAccount}).then(console.log);}
document.getElementById("state").value = currentState;
				})

var gameState = { "betOpen" : 1, "betWaiting": 2, "betClosed": 3};
//console.log("currentState", currentState);

//function offerBet()