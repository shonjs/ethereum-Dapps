pragma solidity ^0.5.16;

contract MoneyMarketInterface {
    uint256 public collateralRatio;
    address[] public collateralMarkets;

    function borrow(address asset, uint256 amount) public returns (uint256);

    function supply(address asset, uint256 amount) public returns (uint256);

    function withdraw(address asset, uint256 requestedAmount)
        public
        returns (uint256);

    function repayBorrow(address asset, uint256 amount)
        public
        returns (uint256);

    function getSupplyBalance(address account, address asset)
        public
        view
        returns (uint256);

    function getBorrowBalance(address account, address asset)
        public
        view
        returns (uint256);

    function assetPrices(address asset) public view returns (uint256);

    function calculateAccountValues(address account)
        public
        view
        returns (uint256, uint256, uint256);
}
