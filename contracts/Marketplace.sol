// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IERC20 {
    function transfer(
        address recipient,
        uint amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    function approve(
        address spender,
        uint amount
    ) external returns (bool);

    function mint(
        address account,
        uint amount
    ) external returns (bool);

    function burn(
        address account,
        uint amount
    ) external returns (bool);
}

contract Marketplace {
    address immutable public admin;
    IERC20 immutable public token1;
    IERC20 immutable public token2;

    mapping(address => uint) public token1Balance;
    mapping(address => uint) public token2Balance;
    mapping(address => bool) public scenario1Lock;
    mapping(address => bool) public scenario2Lock;

    // Scenario 1 events
    event DepositToken1(address indexed sender, uint256 amount, uint256 date);
    event BuyToken2(address indexed sender, uint256 date);
    event UpdateToken2Qty(address indexed sender, uint256 amount1, uint256 amount2, uint256 date);
    event WithdrawToken2(address indexed sender, uint256 amount, uint256 date);

    // Scenario 2 events
    event DepositToken2(address indexed sender, uint256 amount, uint256 date);
    event BuyToken1(address indexed sender, uint256 date);
    event UpdateToken1Qty(address indexed sender, uint256 amount, uint256 amount2, uint256 date);
    event WithdrawToken1(address indexed sender, uint256 amount, uint256 date);

    constructor(
        address _token1Address,
        address _token2Address
    ) {
        token1 = IERC20(_token1Address);
        token2 = IERC20(_token2Address);
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    /**
     * Scenario 1 - depositToken1 -> buyToken2 -> updateToken2Qty -> withdrawToken2
     */
    function depositToken1(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        token1Balance[msg.sender] = token1Balance[msg.sender] + _amount;
        emit DepositToken1(msg.sender, _amount, block.timestamp);
        return true;
    }

    function buyToken2() public returns (bool) {
        require(!scenario1Lock[msg.sender], "Address should not be locked");
        scenario1Lock[msg.sender] = true;
        emit BuyToken2(msg.sender, block.timestamp);
        return true;
    }

    function updateToken2Qty(address _account, uint _amount) public onlyAdmin returns (bool) {
        require(_account != address(0), "Account cannot be zero");
        require(_amount > 0, "Amount cannot be zero");
        require(scenario1Lock[msg.sender], "Address should be locked");
        require(token1Balance[_account] > 0, "Token1 balance cannot be zero");
        token2Balance[_account] = token2Balance[_account] + _amount;
        token1Balance[_account] = 0;
        token2.mint(address(this), _amount);
        token2.approve(_account, _amount);
        scenario1Lock[msg.sender] = false;
        emit UpdateToken2Qty(_account, token1Balance[_account], _amount, block.timestamp);
        return true;
    }

    function withdrawToken2(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        require(!scenario1Lock[msg.sender], "Address is locked");
        token2Balance[msg.sender] = token2Balance[msg.sender] - _amount;
        token2.transferFrom(address(this), msg.sender, _amount);
        emit WithdrawToken2(msg.sender, _amount, block.timestamp);
        return true;
    }

    /**
    * Scenario 2 - depositToken2 -> buyToken1 -> updateToken1Qty -> withdrawToken1
    */
    function depositToken2(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        token2Balance[msg.sender] = token2Balance[msg.sender] + _amount;
        emit DepositToken2(msg.sender, _amount, block.timestamp);
        return true;
    }

    function buyToken1() public returns (bool) {
        require(!scenario2Lock[msg.sender], "Address should not be locked");
        scenario2Lock[msg.sender] = true;
        emit BuyToken1(msg.sender, block.timestamp);
        return true;
    }

    function updateToken1Qty(address _account, uint _amount) public onlyAdmin returns (bool) {
        require(_account != address(0), "Account cannot be zero");
        require(_amount > 0, "Amount cannot be zero");
        require(scenario2Lock[msg.sender], "Address should be locked");
        require(token2Balance[_account] > 0, "Token1 balance cannot be zero");
        token1Balance[_account] = token1Balance[_account] + _amount;
        token2Balance[_account] = 0;
        token2.burn(address(this), _amount);
        token1.approve(_account, _amount);
        scenario2Lock[msg.sender] = false;
        emit UpdateToken1Qty(_account, token2Balance[_account], _amount, block.timestamp);
        return true;
    }

    function withdrawToken1(uint _amount) public returns (bool) {
        require(_amount > 0, "Amount cannot be zero");
        require(!scenario2Lock[msg.sender], "Address is locked");
        token1Balance[msg.sender] = token1Balance[msg.sender] - _amount;
        token1.transferFrom(address(this), msg.sender, _amount);
        emit WithdrawToken1(msg.sender, _amount, block.timestamp);
        return true;
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