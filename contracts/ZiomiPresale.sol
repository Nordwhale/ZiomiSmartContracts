import './SafeMath.sol';
import './Ownable.sol';
import './ZiomiToken.sol';


pragma solidity ^0.4.8;


/// @title ZiomiPresale crowdsale
contract ZiomiPresale is Ownable, SafeMath {
  ZiomiToken public ziomiToken;       // token that will be sold during sale
  bool public presaleClosed;        // whether the crowdsale has been closed
  mapping (address => uint256) public etherBalances;

  uint public etherReceived;       // total ether received
  uint public constant DISCOUNT = 50; //percent

  // number of tokens sold during presale
  uint public constant PRESALE_TOKEN_AMOUNT = 60000000;

  // smallest possible donation
  uint public constant MINIMUM_BUY = 1000; //usd purchase limit
  uint public constant USD_RATE = 200; //usd per 1 eth
  uint startTime;

  uint endTime;


  event Buy(address indexed donor, uint amount, uint tokenAmount);

  event LogUint(uint value);

  event LogBool(bool value);

  modifier onlyDuringSale() {
    require(!presaleClosed);
    require(now >= startTime);
    require(now <= endTime);
    _;
  }

  function ZiomiPresale(address ziomiTokenAddress, uint _startTime, uint _endTime) {
    require(_endTime > _startTime);
    presaleClosed = false;
    ziomiToken = ZiomiToken(ziomiTokenAddress);
    startTime = _startTime;
    endTime = _endTime;
  }

  function getTokenAmount(uint amount) constant returns (uint) {
    if (amount == 0) return 0;
    uint tokenAmount = safeDiv(amount, ziomiToken.getTokenRate());
    return safeMul(tokenAmount, safeDiv(100, DISCOUNT));
  }

  modifier minimumBuy(){
    require(safeDiv(safeMul(msg.value, USD_RATE), 1 ether) >= MINIMUM_BUY);
    _;
  }

  function checkPresaleTokenAmount(uint tokenAmount) constant returns (bool) {
    return safeAdd(tokenAmount, ziomiToken.getTotalSupply()) <= PRESALE_TOKEN_AMOUNT;
  }

  /// @dev buy tokens, only usable while crowdsale is active
  function processBuy() minimumBuy internal returns (bool) {
    uint amount = msg.value;
    uint tokenAmount = getTokenAmount(amount);

    require(checkPresaleTokenAmount(tokenAmount));
    require(ziomiToken.create(msg.sender, tokenAmount));

    etherBalances[msg.sender] += amount;
    etherReceived = safeAdd(etherReceived, amount);

    Buy(msg.sender, amount, tokenAmount);
    return true;
  }

  // grant tokens to buyer when we receive ether
  function() payable onlyDuringSale {
    require(processBuy());
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return etherBalances[_owner];
  }

  event Finalize(uint totalFinalizeSupply, uint etherFinalizeReceived);
  /// @dev close the crowdsale and unlock the tokens
  function finalize() onlyOwner {
    require(!presaleClosed);
    require(now >= endTime);
    presaleClosed = true;
    Finalize(ziomiToken.getTotalSupply(), etherReceived);
  }
}



