// SPDX-License-Identifier: MIT
// 0x3df695D73e4cB5B8Ab80f0CE861fC30BbB7b7483
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "hardhat/console.sol";

contract SUSDG is ERC20 {
    address immutable public admin;
    address public minter;
    address public burner;

    constructor() ERC20("SUSDG", "SUSDG") {
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