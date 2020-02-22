require("dotenv").config();
const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const interface = require("../build/contracts/TokenBorrowerFactory");
const Tx = require("ethereumjs-tx").Transaction;

// Environment Variables
const network = "kovan";
const nodeUrls = JSON.parse(process.env.NODE_URL);
const nodeUrl = nodeUrls[network];
const cETHAddresses = JSON.parse(process.env.cETH_CONTRACT_ADDRESS);
const contractDeployedAddress = cETHAddresses[network];
const userAddress = process.env.USER_ADDRESS;
const mnemonic = process.env.WALLET_MNEMONIC;
const provider = new HDWalletProvider(mnemonic, nodeUrl);

var web3 = new Web3(provider);

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

function getBorrowers(borrower) {
  borrower.methods
    .borrowers(userAddress)
    .call()
    .then(log);
}

getBorrowers(borrower);

async function borrow(borrower, collateralValue) {
  //   const gas = await web3.eth.estimateGas({
  //     to: contractDeployedAddress,
  //     data: ""
  //   });
  //   const txCount = await web3.eth.getTransactionCount(userAddress, "pending");
  //   const rawTx = {
  //     // from: userAddress,
  //     nonce: web3.utils.numberToHex(txCount),
  //     to: contractDeployedAddress,
  //     gasPrice: web3.utils.toHex(20 * 1e9),
  //     gasLimit: web3.utils.toHex(210000),
  //     value: web3.utils.numberToHex(web3.utils.toWei(collateralValue)),
  //     data: "0x00"
  //     // chainId: 4,
  //     // chain: 4
  //   };

  //   const tx = new Tx(rawTx, { chain: "rinkeby" });
  //   const signedTx = await web3.eth.sign(rawTx, userAddress);

  const txOptions = {
    from: userAddress,
    gasPrice: "20000000000",
    gas: "150000",
    to: contractDeployedAddress,
    value: web3.utils.toWei(collateralValue),
    data: ""
  };

  //   web3.eth
  //     .call({
  //       to: contractDeployedAddress,
  //       data: "0x" + tx
  //     })
  //     .then(log);
  //   return;

  const signedTx = await web3.eth.signTransaction(txOptions);

  web3.eth
    .sendSignedTransaction(signedTx.raw)
    .on("receipt", log)
    .on("error", (error, receipt) => {
      //   log(receipt, "receipt");
      log(error, "error");
    });
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
