const Web3 = require("web3");
const interface = require("../build/contracts/Borrower.json");

var web3 = new Web3("http://localhost:8545");

// web3.eth.getAccounts().then(accounts => console.log(accounts));

let borrower = new web3.eth.Contract(
  interface.abi,
  "0xce18044fc66b61422fce288b4b9089c9442da832"
);

console.log("Borrower", borrower);
