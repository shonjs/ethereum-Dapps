pragma solidity ^0.5.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./WETHInterface.sol";
import "./MoneyMarketInterface.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Borrower {
    using SafeMath for uint256;
    uint256 constant expScale = 10**18;
    uint256 constant collateralRatioBuffer = 25 * 10**16;
    address creator;
    address payable owner;
    WETHInterface weth;
    MoneyMarketInterface compoundMoneyMarket;
    IERC20 borrowedToken;

    event Log(uint256 x, string m);
    event Log(int256 x, string m);

    constructor(
        address payable _owner,
        address tokenAddress,
        address wethAddress,
        address moneyMarketAddress
    ) public {
        creator = msg.sender;
        owner = _owner;
        borrowedToken = IERC20(tokenAddress);
        compoundMoneyMarket = MoneyMarketInterface(moneyMarketAddress);
        weth = WETHInterface(wethAddress);

        weth.approve(moneyMarketAddress, uint256(-1));
        borrowedToken.approve(address(compoundMoneyMarket), uint256(-1));
    }

    /*
    @dev called from borrow factory, wraps eth and supplies weth, then borrows
     the token at address supplied in constructor
  */
    function fund() external payable {
        require(creator == msg.sender);

        weth.deposit.value(msg.value)();

        uint256 supplyStatus = compoundMoneyMarket.supply(
            address(weth),
            msg.value
        );
        require(supplyStatus == 0, "supply failed");

        /* --------- borrow the tokens ----------- */
        uint256 collateralRatio = compoundMoneyMarket.collateralRatio();
        (uint256 status, uint256 totalSupply, uint256 totalBorrow) = compoundMoneyMarket
            .calculateAccountValues(address(this));
        require(status == 0, "calculating account values failed");

        uint256 availableBorrow = findAvailableBorrow(
            totalSupply,
            totalBorrow,
            collateralRatio
        );

        uint256 assetPrice = compoundMoneyMarket.assetPrices(
            address(borrowedToken)
        );
        /*
      available borrow & asset price are both scaled 10e18, so include extra
      scale in numerator dividing asset to keep it there
    */
        uint256 tokenAmount = availableBorrow.mul(expScale).div(assetPrice);
        uint256 borrowStatus = compoundMoneyMarket.borrow(
            address(borrowedToken),
            tokenAmount
        );
        require(borrowStatus == 0, "borrow failed");

        /* ---------- sweep tokens to user ------------- */
        uint256 borrowedTokenBalance = borrowedToken.balanceOf(address(this));
        borrowedToken.transfer(owner, borrowedTokenBalance);
    }

    /* @dev the factory contract will transfer tokens necessary to repay */
    function repay() external {
        require(creator == msg.sender);

        uint256 repayStatus = compoundMoneyMarket.repayBorrow(
            address(borrowedToken),
            uint256(-1)
        );
        require(repayStatus == 0, "repay failed");

        /* ---------- withdraw excess collateral weth ------- */
        uint256 collateralRatio = compoundMoneyMarket.collateralRatio();
        (uint256 status, uint256 totalSupply, uint256 totalBorrow) = compoundMoneyMarket
            .calculateAccountValues(address(this));
        require(status == 0, "calculating account values failed");

        uint256 amountToWithdraw;
        if (totalBorrow == 0) {
            amountToWithdraw = uint256(-1);
        } else {
            amountToWithdraw = findAvailableWithdrawal(
                totalSupply,
                totalBorrow,
                collateralRatio
            );
        }

        uint256 withdrawStatus = compoundMoneyMarket.withdraw(
            address(weth),
            amountToWithdraw
        );
        require(withdrawStatus == 0, "withdrawal failed");

        /* ---------- return ether to user ---------*/
        uint256 wethBalance = weth.balanceOf(address(this));
        weth.withdraw(wethBalance);
        owner.transfer(address(this).balance);
    }

    /* @dev returns borrow value in eth scaled to 10e18 */
    function findAvailableBorrow(
        uint256 currentSupplyValue,
        uint256 currentBorrowValue,
        uint256 collateralRatio
    ) public pure returns (uint256) {
        uint256 totalPossibleBorrow = currentSupplyValue.mul(expScale).div(
            collateralRatio.add(collateralRatioBuffer)
        );
        if (totalPossibleBorrow > currentBorrowValue) {
            return totalPossibleBorrow.sub(currentBorrowValue).div(expScale);
        } else {
            return 0;
        }
    }

    /* @dev returns available withdrawal in eth scale to 10e18 */
    function findAvailableWithdrawal(
        uint256 currentSupplyValue,
        uint256 currentBorrowValue,
        uint256 collateralRatio
    ) public pure returns (uint256) {
        uint256 requiredCollateralValue = currentBorrowValue
            .mul(collateralRatio.add(collateralRatioBuffer))
            .div(expScale);
        if (currentSupplyValue > requiredCollateralValue) {
            return
                currentSupplyValue.sub(requiredCollateralValue).div(expScale);
        } else {
            return 0;
        }
    }

    /* @dev it is necessary to accept eth to unwrap weth */
    function() external payable {}
}
