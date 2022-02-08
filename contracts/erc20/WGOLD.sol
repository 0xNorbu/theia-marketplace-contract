// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract WGOLD is ERC20 {
    address immutable public admin;
    address public banker;

    constructor() ERC20("WGOLD", "WGOLD") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyAdminOrBanker() {
        require(msg.sender == admin || msg.sender == banker,
            "Not admin or banker");
        _;
    }

    function setBanker(address _banker) public onlyAdmin {
        banker = _banker;
    }

    // Allow admin / banker to mint the token
    function mint(address account, uint amount) public onlyAdminOrBanker returns (bool){
        _mint(account, amount);
        return true;
    }

    // Allow admin / banker to burn the token
    function burn(address account, uint amount) public onlyAdminOrBanker returns (bool){
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