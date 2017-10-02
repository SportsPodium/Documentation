pragma solidity ^0.4.13;

import '../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol';
import '../node_modules/zeppelin-solidity/contracts/token/PausableToken.sol';

contract PodCoin is MintableToken, PausableToken {
  string public name = "Podium";
  string public symbol = "POD";
  uint256 public decimals = 9;
}