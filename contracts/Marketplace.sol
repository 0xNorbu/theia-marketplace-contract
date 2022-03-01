// SPDX-License-Identifier: MIT
// Swapping =>
// User can swap USDC for USDG
// User can swap pUSG for USDG
//
// Buying bond =>
// User can swap USDC for pUSDG
//
// Selling bond =>
// User can swap pUSDG for USDC
pragma solidity 0.8.0;

import "hardhat/console.sol";

interface IERC20WithMintAndBurn {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external returns (uint);
    function mint(address account, uint amount) external returns (bool);
    function burn(address account, uint amount) external returns (bool);
    function setMinter(address _banker) external;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint value
    );
}

contract Marketplace {
    address public admin;

    IERC20WithMintAndBurn public usdcToken;
    IERC20WithMintAndBurn public usdgToken;
    IERC20WithMintAndBurn public pusdgToken;

    address[] public registerAddressArray;
    mapping(address => bool) public registerAddress;

    constructor(
        address _usdcAddress,
        address _usdgAddress,
        address _pusdgAddress
    ) {
        usdcToken = IERC20WithMintAndBurn(_usdcAddress);
        usdgToken = IERC20WithMintAndBurn(_usdgAddress);
        pusdgToken = IERC20WithMintAndBurn(_pusdgAddress);
        admin = msg.sender;
    }

    event SWAP_USDC_FOR_USDG(address indexed from, uint indexed amount, uint timestamp);
    event SWAP_PUSDG_FOR_USDG(address indexed from, uint indexed amount, uint timestamp);
    event SWAP_USDC_FOR_PUSDG(address indexed from, uint indexed amount, uint timestamp);
    event SWAP_PUSDG_FOR_USDC(address indexed from, uint indexed amount, uint timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable _admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        admin = _admin;
    }

    // 1 - Contract accepts sender's USDC
    // 2 - Contract mints USDG to sender
    function swapUSDCForUSDG(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        usdcToken.transferFrom(msg.sender, address(this), _amount);
        usdgToken.mint(msg.sender, _amount);
        emit SWAP_USDC_FOR_USDG(msg.sender, _amount, block.timestamp);
        return true;
    }

    // 1 - Contract burns sender's PUSDG
    // 2 - Contract mints USDG to sender
    function swapPUSDGForUSDG(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        pusdgToken.burn(msg.sender, _amount);
        usdgToken.mint(msg.sender, _amount);
        emit SWAP_PUSDG_FOR_USDG(msg.sender, _amount, block.timestamp);
        return true;
    }

    // Bond
    // 1 - Contract accepts sender's USDC
    // 2 - Contract mints PUSDG to sender
    function swapUSDCForPUSDG(uint _amount) public returns (bool){
        require(_amount > 0, "Amount cannot be zero");
        usdcToken.transferFrom(msg.sender, address(this), _amount);
        pusdgToken.mint(msg.sender, _amount * 997 / 1000);
        emit SWAP_USDC_FOR_PUSDG(msg.sender, _amount, block.timestamp);
        return true;
    }

    // 1 - Contract burns sender's PUSDG
    // 2 - Contract transfer USDG to sender
    function swapPUSDGForUSDC(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        pusdgToken.burn(msg.sender, _amount);
        usdcToken.transfer(msg.sender, _amount);
        emit SWAP_PUSDG_FOR_USDG(msg.sender, _amount, block.timestamp);
        return true;
    }

    function withdrawPusdgToken() public onlyAdmin{
        usdcToken.transfer(admin, address(this).balance);
    }

    // Allow admin to send back the token that is wrongly sent to this contract
    function recover(address tokenAddress, address recoveryAddress, uint amount) public onlyAdmin {
        IERC20WithMintAndBurn(tokenAddress).transfer(recoveryAddress, amount);
    }

    // Reject all native coin deposit
    receive() external payable {
        revert();
    }
}