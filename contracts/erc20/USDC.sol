// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "hardhat/console.sol";

contract USDC is ERC20 {
    address immutable public admin;
    address public minter;
    address public burner;

    constructor() ERC20("USDC", "USDC") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Allow admin / minter to mint the token
    function mint(address account, uint amount) public onlyAdmin returns (bool){
        _mint(account, amount);
        return true;
    }

    // Allow admin / minter to burn the token
    function burn(address account, uint amount) public onlyAdmin returns (bool){
        _burn(account, amount);
        return true;
    }

    // Allow admin to send back token that is wrongly sent to this contract
    function recover(address tokenAddress, address recoveryAddress, uint amount) public onlyAdmin{
        IERC20(tokenAddress).transfer(recoveryAddress, amount);
    }

    // Reject all native coin deposit
    receive() external payable {
        revert();
    }
}