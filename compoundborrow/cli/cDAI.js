require("dotenv").config();
const network = "kovan";
const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = process.env.WALLET_MNEMONIC;
const urls = JSON.parse(process.env.NODE_URL);
const nodeUrl = urls[network];
const provider = new HDWalletProvider(mnemonic, nodeUrl);
const Web3 = require("web3");
var web3 = new Web3(provider);

const cDAIinterface = require("../abi/cDAI.json");
const Tx = require("ethereumjs-tx").Transaction;
const { log } = require("./utils");

//DAI
const daiContractAddress = JSON.parse(process.env.DAI_CONTRACT_ADDRESS)[
  network
];
const daiAbiJson = require("../abi/DAI.json");
const daiContract = new web3.eth.Contract(daiAbiJson, daiContractAddress);

const myWalletAddress = process.env.USER_ADDRESS;
const addresses = JSON.parse(process.env.cDAI_CONTRACT_ADDRESS);
const cDAIContractAddress = addresses[network];

const compoundcDAIContract = new web3.eth.Contract(
  cDAIinterface,
  cDAIContractAddress
);

const dai = 1e18;

web3.eth.handleRevert = true;

daiContract.methods
  .approve(cDAIContractAddress, web3.utils.toBN(dai))
  .send({
    from: myWalletAddress,
    gasLimit: web3.utils.toHex(150000),
    gasPrice: web3.utils.toHex(20000000000)
  })
  .then(result => {
    log("DAI approved for minting");
    log("Sending DAI to compound");
    return compoundcDAIContract.methods.mint(web3.utils.toBN(dai)).send({
      from: myWalletAddress,
      gasLimit: web3.utils.toHex(600000),
      gasPrice: web3.utils.toHex(20000000000)
    });
  })
  .then(result => {
    console.log('cDAI "Mint" operation successful.');
    return compoundcDAIContract.methods
      .balanceOfUnderlying(myWalletAddress)
      .call();
  })
  .then(balanceOfUnderlying => {
    balanceOfUnderlying = web3.utils.fromWei(balanceOfUnderlying).toString();
    console.log("DAI supplied to the Compound Protocol:", balanceOfUnderlying);
    return compoundcDAIContract.methods.balanceOf(myWalletAddress).call();
  })
  .then(cTokenBalance => {
    cTokenBalance = (cTokenBalance / 1e8).toString();
    console.log("My wallet's cDAI Token Balance:", cTokenBalance);
  })
  .catch((error, receipt) => {
    console.error(error);
    if (receipt) log("receipt", receipt);
  });
