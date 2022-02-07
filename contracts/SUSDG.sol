// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SUSDG is ERC20 {
    address immutable public admin;

    constructor() ERC20("SUSDG", "SUSDG") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Allow admin to mint the token
    function mint(address account, uint amount) public onlyAdmin {
        _mint(account, amount);
    }

    // Allow admin to burn the token
    function burn(address account, uint amount) public onlyAdmin {
        _burn(account, amount);
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