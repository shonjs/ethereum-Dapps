require("dotenv").config();
const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const interface = require("../abi/cETH.json");
const Tx = require("ethereumjs-tx").Transaction;

const nodeUrl = process.env.RINKEBY_URL;
const mnemonic = process.env.WALLET_MNEMONIC;
const myWalletAddress = process.env.USER_ADDRESS;
const provider = new HDWalletProvider(mnemonic, nodeUrl);
const addresses = JSON.parse(process.env.cETH_CONTRACT_ADDRESS);
const contractAddress = addresses["rinkeby"];

var web3 = new Web3(provider);

// const contractAddress = "0xd6801a1dffcd0a410336ef88def4320d6df1883e"; // rikeby
const compoundCEthContract = new web3.eth.Contract(interface, contractAddress);

// Mint some cETH by supplying ETH to the Compound Protocol
console.log("Sending ETH to the Compound Protocol...");

compoundCEthContract.methods
  .mint()
  .send({
    from: myWalletAddress,
    gasLimit: web3.utils.toHex(150000), // posted at compound.finance/developers#gas-costs
    gasPrice: web3.utils.toHex(20000000000), // use ethgasstation.info (mainnet only)
    value: web3.utils.toHex(web3.utils.toWei("0.001", "ether"))
  })
  .then(result => {
    console.log('cETH "Mint" operation successful.');
    return compoundCEthContract.methods
      .balanceOfUnderlying(myWalletAddress)
      .call();
  })
  .then(balanceOfUnderlying => {
    balanceOfUnderlying = web3.utils.fromWei(balanceOfUnderlying).toString();
    console.log("ETH supplied to the Compound Protocol:", balanceOfUnderlying);
    return compoundCEthContract.methods.balanceOf(myWalletAddress).call();
  })
  .then(cTokenBalance => {
    cTokenBalance = (cTokenBalance / 1e8).toString();
    console.log("My wallet's cETH Token Balance:", cTokenBalance);
  })
  .catch(error => {
    console.error(error);
  });
