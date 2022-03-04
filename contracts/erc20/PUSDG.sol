// SPDX-License-Identifier: MIT
// 0x3609C8B2006Db28BD7AFE91Feb7804977F4E9F73
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "hardhat/console.sol";

contract PUSDG is ERC20 {
    address immutable public admin;
    address public minter;
    address public burner;

    constructor() ERC20("PUSDG", "PUSDG") {
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

    modifier onlyAdminOrBurner() {
        require(msg.sender == admin || msg.sender == burner,
            "Not admin or burner");
        _;
    }

    function setMinter(address _minter) public onlyAdmin {
        minter = _minter;
    }

    function setBurner(address _burner) public onlyAdmin {
        burner = _burner;
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    // Allow admin / minter to mint the token
    function mint(address account, uint amount) public onlyAdminOrMinter returns (bool){
        _mint(account, amount);
        return true;
    }

    // Allow admin / minter to burn the token
    function burn(address account, uint amount) public onlyAdminOrBurner returns (bool){
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