require('dotenv').config();
var Web3 = require('web3');
var ENS = require('ethereum-ens');
console.log("Current provider", process.env.CONNECTION_MAINNET_HTTP);
//var provider = new Web3.providers.WebsocketProvider(process.env.CONNECTION_MAINNET_WS);
var provider = new Web3.providers.HttpProvider(process.env.CONNECTION_MAINNET_HTTP);
var web3 = new Web3(provider);
console.log(web3);
setTimeout(function(){
	var ens = new ENS(provider);
	var address = ens.resolver(process.env.SCOTT_ETH).addr()
					.then(function(addr){
						console.log(addr);
					});
}, 3000);
