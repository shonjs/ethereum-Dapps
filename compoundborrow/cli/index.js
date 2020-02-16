require("dotenv").config();
const Web3 = require("web3");
const interface = require("../build/contracts/TokenBorrowerFactory");

// Environment Variables
const nodeUrl = process.env.RINKEBY_URL;
const contractDeployedAddress = process.env.RINKEBY_CONTRACT_ADDRESS;
const userAddress = process.env.USER_ADDRESS;

var web3 = new Web3(nodeUrl);

function log(message, label) {
  if (label) {
    console.log(label + " : ", message);
  } else {
    console.log(message);
  }
}

let borrower = new web3.eth.Contract(interface.abi, contractDeployedAddress);

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

let command = process.argv[2];
if (!command) {
  log("token fund");
}

switch (command) {
  case "token":
    getCurrentBorrow(borrower);
    break;
  case "fund":
    getFundBalance(borrower);
    break;
}
