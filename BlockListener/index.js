require('dotenv').config();
var Web3 = require("web3");
console.log(process.env.MAINNET_URL);
var web3 = new Web3(new Web3.providers.WebsocketProvider(process.env.MAINNET_URL));
var avgTps = 0;
var blockCount = 0;

web3.eth.subscribe('newBlockHeaders', function(error, result){
})
.on("data", function(blockHeader){
	//console.log("block number", blockHeader.number);
	//console.log("block timestamp", blockHeader.timestamp);
	getBlockTime(blockHeader);
});

var getBlockTime = function(currentBlock){
	getBlock(currentBlock.parentHash).then(previousBlock=>{
		//console.log("block timestamp previous", previousBlock.timestamp);
		let currentBlockTime = (currentBlock.timestamp - previousBlock.timestamp);
		//console.log("BlockTime", currentBlockTime);
		getTps(currentBlock.hash, currentBlockTime);
	});
}

var getBlock = function(blockHashOrNumber){
	return web3.eth.getBlock(blockHashOrNumber);
}

var getBlockTransactionCount = function(blockHashOrNumber){
	return web3.eth.getBlockTransactionCount(blockHashOrNumber);
}

var getTps = function(blockHash, blockTime){
	getBlockTransactionCount(blockHash)
	.then(txCount=>{
		//console.log("TxCount", txCount);
		let tps = txCount/blockTime;
		avgTps = ((avgTps || tps) + tps)/2;
		blockCount++;
		console.log("Block", blockCount);
		console.log("TPS", tps);
		console.log("AVG TPS", avgTps);
		console.log();
	})
}