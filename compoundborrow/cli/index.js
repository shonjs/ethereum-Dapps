require("dotenv").config();
const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const interface = require("../build/contracts/TokenBorrowerFactory");
const Tx = require("ethereumjs-tx").Transaction;

// Environment Variables
const nodeUrl = process.env.RINKEBY_URL;
const contractDeployedAddress = process.env.RINKEBY_CONTRACT_ADDRESS;
const userAddress = process.env.USER_ADDRESS;
const mnemonic = process.env.WALLET_MNEMONIC;
const provider = new HDWalletProvider(mnemonic, nodeUrl);

var web3 = new Web3(provider);

function log(message, label) {
  if (label) {
    console.log(label + " : ", message);
  } else {
    console.log(message);
  }
}

let borrower = new web3.eth.Contract(interface.abi, contractDeployedAddress);
borrower.handleRevert = true;

function getCurrentBorrow(borrower) {
  borrower.methods
    .getBorrowBalance(userAddress)
    .call()
    .then(log);
}

function getFundBalance(borrower) {
  borrower.methods
    .getSupplyBalance(userAddress)
    .call()
    .then(log);
}

async function borrow(borrower, collateralValue) {
  //   const gas = await web3.eth.estimateGas({
  //     to: contractDeployedAddress,
  //     data: ""
  //   });
  const txCount = await web3.eth.getTransactionCount(userAddress, "pending");
  //   const rawTx = {
  //     // from: userAddress,
  //     nonce: txCount,
  //     to: contractDeployedAddress,
  //     gasPrice: web3.utils.toHex(20 * 1e9),
  //     gasLimit: web3.utils.toHex(210000),
  //     value: web3.utils.toWei(collateralValue)
  //     // chainId: 4,
  //     // chain: 4
  //   };

  //   const tx = new Tx(rawTx, { chain: "rinkeby" });
  //   const signedTx = await web3.eth.sign(rawTx, userAddress);

  const txOptions = {
    from: userAddress,
    gasPrice: "20000000000",
    gas: "21000",
    to: contractDeployedAddress,
    value: web3.utils.toWei(collateralValue),
    data: ""
  };

  const signedTx = await web3.eth.signTransaction(txOptions);

  web3.eth
    .sendSignedTransaction(signedTx.raw)
    .on("receipt", log)
    .on("error", (error, receipt) => {
      log(receipt, "receipt");
      log(error, "error");
    });

  //   web3.eth.accounts.signTransaction(transaction).then(log);
}

let command = process.argv[2];
if (!command) {
  log("balancet balancef fund");
}

switch (command) {
  case "balancet":
    getCurrentBorrow(borrower);
    break;
  case "balancef":
    getFundBalance(borrower);
    break;
  case "fund":
    let amountToFund = process.argv[3];
    if (!amountToFund || !parseFloat(amountToFund)) {
      log("Please give valid amount for collateral");
    }
    borrow(borrower, parseFloat(amountToFund).toString());
    break;
}

function exit() {
  provider.engine.stop();
}

exit();
