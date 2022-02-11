// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "hardhat/console.sol";

contract BUSD is ERC20 {
    address immutable public admin;
    address public minter;

    constructor() ERC20("BUSD", "BUSD") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyAdminOrMinter() {
        require(msg.sender == admin || msg.sender == minter,
            "Not admin or minter");
        _;
    }

    function setMinter(address _minter) public onlyAdmin {
        minter = _minter;
    }

    // Allow admin / minter to mint the token
    function mint(address account, uint amount) public onlyAdminOrMinter returns (bool){
        _mint(account, amount);
        return true;
    }

    // Allow admin / minter to burn the token
    function burn(address account, uint amount) public onlyAdminOrMinter returns (bool){
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