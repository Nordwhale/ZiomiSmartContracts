import './StandardToken.sol';
import './Ownable.sol';


pragma solidity ^0.4.14;


contract ZiomiToken is StandardToken, Ownable {

  string public constant name = "Ziomi Token";

  string public constant symbol = "ZMI";

  uint8 public constant decimals = 18;

  // don't allow creation of more than this number of tokens
  uint public constant MAX_TOKENS = 350000000;

  uint public constant TOKEN_RATE = 100; // 1ETH = 100 ZMI

  // whether transfers are locked
  bool public locked = true;

  address public creator;

  modifier onlyCreatorOrOwner() {
    require(msg.sender == creator || msg.sender == owner);
    _;
  }

  function setCreatorAddress(address newCreator) onlyOwner {
    if (newCreator != address(0)) {
      creator = newCreator;
    }
  }

  // determine whether transfers can be made
  modifier onlyAfterSale() {
    require(!locked);
    _;
  }

  modifier onlyDuringSale() {
    require(locked);
    _;
  }

  /// @dev Create ZiomiToken and lock transfers
  function ZiomiToken() {
    locked = true;
  }

  function getTotalSupply() constant returns (uint){
    return totalSupply;
  }

  function getTokenRate() constant returns (uint){
    return 1 ether / TOKEN_RATE;
  }

  event Unlock(uint time);

  /// @dev unlock transfers
  /// @return true if successful
  function unlock() onlyOwner returns (bool) {
    locked = false;
    Unlock(now);
    return true;
  }

  function getLocked() constant returns (bool){
    return locked;
  }

  event Create(address indexed _to, uint _value);
  /// @dev create tokens, only usable while locked
  /// @param recipient address that will receive the created tokens
  /// @param amount the number of tokens to create
  /// @return true if successful
  function create(address recipient, uint amount) onlyCreatorOrOwner onlyDuringSale returns (bool) {
    require(amount > 0);
    require((totalSupply + amount) < MAX_TOKENS);
    balances[recipient] = safeAdd(balances[recipient], amount);
    totalSupply = safeAdd(totalSupply, amount);
    Create(recipient, amount);
    return true;
  }

  // transfer tokens
  // only allowed after sale has ended
  function transfer(address _to, uint _value) onlyAfterSale returns (bool) {
    return super.transfer(_to, _value);
  }

  // transfer tokens
  // only allowed after sale has ended
  function transferFrom(address from, address to, uint value) onlyAfterSale
  returns (bool)
  {
    return super.transferFrom(from, to, value);
  }
}
