// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IERC20 {
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

contract Swapper {
    address public admin;

    IERC20 public usdcToken;  // External USD stable coin
    IERC20 public wpaxgToken; // Internal pegged gold coin
    IERC20 public pusdgToken; // pre-usdg coin. User needs to deposit usdg or wpaxg to buy this coin
    IERC20 public usdgToken;  // Internal USD stable coin

    address[] public registerAddressArray;
    mapping(address => bool) public registerAddress;
    mapping(address => bool) public scenario2Lock;

    constructor(
        address _usdcAddress,
        address _wpaxgAddress,
        address _pusdgAddress
    ) {
        usdcToken  = IERC20(_usdcAddress);
        wpaxgToken = IERC20(_wpaxgAddress);
        pusdgToken = IERC20(_pusdgAddress);
        admin = msg.sender;
    }

    event SWAP_USDC_FOR_WPAXG(address indexed from, uint indexed usdcAmount, uint indexed wpagxAmount, uint timestamp);
    event SWAP_USDC_FOR_USDG(address indexed from, uint indexed amount, uint timestamp);
    event SWAP_PUSDG_FOR_USDG(address indexed from, uint indexed amount, uint timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable _admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        admin = _admin;
    }

    function swapUSDCForWPAXG(uint _amount) public returns (uint) {
        uint _goldAmount = _swapForUSDStableTokenForGoldStableToken(usdcToken, wpaxgToken, _amount);
        emit SWAP_USDC_FOR_WPAXG(msg.sender, _amount, _goldAmount, block.timestamp);
        return _goldAmount;
    }

    function swapUSDCForUSDG(uint _amount) public returns (uint) {
        emit SWAP_USDC_FOR_USDG(msg.sender, _amount, block.timestamp);
        return _swapForTwoStableTokens(usdcToken, usdgToken, _amount);
    }

    // Bond
    function swapUSDCForPUSDG(uint _amount) public returns (uint){
        emit SWAP_USDC_FOR_PUSDG(msg.sender, _amount, block.timestamp);
        return _swapForTwoStableTokens(usdcToken, pusdgToken, _amount);
    }

    // Bond
    function swapWPAXGForPUSDG(uint _amount) public returns (uint){
        emit SWAP_USDC_FOR_WPAXG(msg.sender, _amount, block.timestamp);
        return _swapForTwoStableTokens(usdcToken, usdgToken, _amount);
    }

    function swapPUSDGForUSDG(uint _amount) public returns (uint) {
        emit SWAP_USDC_FOR_USDG(msg.sender, _amount, block.timestamp);
        return _swapForTwoStableTokens(pusdgToken, usdgToken, _amount);
    }

    function _swapForUSDStableTokenForGoldStableToken(
        IERC20 _erc20USDStableToken,
        IERC20 _erc20GoldStableToken,
        uint _amount
    )  public returns (uint) {
        require(_amount > 0, "Amount cannot be zero");
        _erc20USDStableToken.transferFrom(msg.sender, address(this), _amount);
        uint _goldPricePerUSD = 0; // TODO
        uint _goldAmount = _goldPricePerUSD * _amount;
        _erc20GoldStableToken.mint(msg.sender, _goldAmount);
        return _goldAmount;
    }

    function _swapForGoldStableTokenForUSDStableToken(
        IERC20 _erc20GoldStableToken,
        IERC20 _erc20USDStableToken,
        uint _amount
    )  public returns (uint) {
        require(_amount > 0, "Amount cannot be zero");
        _erc20GoldStableToken.transferFrom(msg.sender, address(this), _amount);
        uint _goldPricePerUSD = 0; // TODO
        uint _usdAmount = _amount / _goldPricePerUSD;
        _erc20USDStableToken.mint(msg.sender, _usdAmount);
        return _goldAmount;
    }

    function _swapForTwoStableTokens(
        IERC20 _erc20StableToken1,
        IERC20 _erc20StableToken2,
        uint _amount
    )  public returns (uint) {
        require(_amount > 0, "Amount cannot be zero");
        _erc20StableToken1.burn(msg.sender, _amount);
        _erc20StableToken2.mint(msg.sender, _amount);
        return _amount;
    }

    // Allow admin to send back the token that is wrongly sent to this contract
    function recover(address tokenAddress, address recoveryAddress, uint amount) public onlyAdmin {
        IERC20(tokenAddress).transfer(recoveryAddress, amount);
    }

    // Reject all native coin deposit
    receive() external payable {
        revert();
    }
}