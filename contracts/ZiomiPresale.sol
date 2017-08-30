import './SafeMath.sol';
import './Ownable.sol';
import './ZiomiToken.sol';


pragma solidity ^0.4.8;


/// @title ZiomiPresale crowdsale
contract ZiomiPresale is Ownable, SafeMath {
  ZiomiToken public ziomiToken;       // token that will be sold during sale
  bool public presaleClosed;        // whether the crowdsale has been closed
  mapping (address => uint256) public etherBalances;

  uint256 public etherReceived;       // total ether received
  uint256 public constant DISCOUNT = 50; //percent

  // number of tokens sold during presale
  uint256 public constant PRESALE_TOKEN_AMOUNT = 60000000;

  // smallest possible donation
  uint256 public constant MINIMUM_BUY = 1000; //usd purchase limit
  uint256 public constant USD_RATE = 200; //usd per 1 eth
  uint256 startTime;
  uint256 endTime;


  event Buy(address indexed donor, uint256 amount, uint256 tokenAmount);

  modifier onlyDuringSale() {
    require(!presaleClosed);
    require(now>=startTime);
    require(now<=endTime);
    _;
  }

  function ZiomiPresale(address ziomiTokenAddress,uint _startTime, uint _endTime) {
    require(_endTime > _startTime);
    presaleClosed = false;
    ziomiToken = ZiomiToken(ziomiTokenAddress);
    startTime = _startTime;
    endTime = _endTime;
  }

  function getTokenAmount(uint256 amount) constant returns (uint256) {
    if (amount == 0) return 0;
    uint256 tokenAmount = safeMul(amount, ziomiToken.getTokenRate());
    return safeMul(tokenAmount, safeDiv(100, DISCOUNT));
  }

  modifier minimumBuy(){
    require(safeMul(msg.value, USD_RATE) <= MINIMUM_BUY);
    _;
  }

  function checkPresaleTokenAmount(uint256 tokenAmount) internal returns (bool) {
    return safeAdd(tokenAmount, ziomiToken.getTotalSupply()) <= PRESALE_TOKEN_AMOUNT;
  }
  /// @dev buy tokens, only usable while crowdsale is active
  function processBuy() minimumBuy internal returns (bool) {
    uint256 amount = msg.value;
    uint256 tokenAmount = getTokenAmount(amount);
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

  event Finalize(uint256 totalFinalizeSupply, uint256 etherFinalizeReceived);
  /// @dev close the crowdsale and unlock the tokens
  function finalize() onlyOwner {
    require(!presaleClosed);
    require(now >= endTime);
    presaleClosed = true;
    Finalize(ziomiToken.getTotalSupply(), etherReceived);
  }
}



