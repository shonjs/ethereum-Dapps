pragma solidity ^0.5.16;

import "./MoneyMarketInterface.sol";
import "./CDP.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBorrowerFactory {
    address wethAddress;
    MoneyMarketInterface compoundMoneyMarket;
    IERC20 token;

    mapping(address => CDP) public borrowers;

    constructor(address weth, address _token, address moneyMarket) public {
        wethAddress = weth;
        token = IERC20(_token);
        compoundMoneyMarket = MoneyMarketInterface(moneyMarket);
    }

    /*
    @notice will deploy a new borrower contract or add funds to an existing one.
    The caller will receive the proceeds of the executed borrow, with a supply
    25% higher than required collateral ratio ( supply / borrow ) being
    targeted. If the additional funds do not put the user in excess of this
    collateral ratio, no borrow will be executed and no tokens will be received.
  */
    function() external payable {
        CDP cdp;
        if (address(borrowers[msg.sender]) == address(0x0)) {
            // create borrower contract if none exists
            cdp = new CDP(
                msg.sender,
                address(token),
                wethAddress,
                address(compoundMoneyMarket)
            );
            borrowers[msg.sender] = cdp;
        } else {
            cdp = borrowers[msg.sender];
        }

        cdp.fund.value(msg.value)();
    }

    /*
    @notice User must approve this contract to transfer the erc 20 token being
     borrowed. Calling this function will repay entire borrow if allowance
     exceeds what is owed, othewise will repay the allowance. The caller will
     receive any excess ether if they are overcollateralized after repaying the
     borrow.
  */
    function repay() public {
        CDP cdp = borrowers[msg.sender];
        uint256 allowance = token.allowance(msg.sender, address(this));
        uint256 borrowBalance = compoundMoneyMarket.getBorrowBalance(
            address(cdp),
            address(token)
        );
        uint256 userTokenBalance = token.balanceOf(msg.sender);
        uint256 transferAmount = min(
            min(allowance, borrowBalance),
            userTokenBalance
        );

        token.transferFrom(msg.sender, address(cdp), transferAmount);
        cdp.repay();
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function getBorrowBalance(address user) public view returns (uint256) {
        return
            compoundMoneyMarket.getBorrowBalance(
                address(borrowers[user]),
                address(token)
            );
    }

    function getSupplyBalance(address user) public view returns (uint256) {
        return
            compoundMoneyMarket.getSupplyBalance(
                address(borrowers[user]),
                wethAddress
            );
    }
}
