pragma solidity ^0.4.11;

import "./CappedCrowdsale.sol";
import "./MintableToken.sol";
import "./PausableToken.sol";


contract PodCoin is MintableToken, PausableToken {
  string public constant name = "Podium";
  string public constant symbol = "POD";
  uint8 public constant decimals = 18;
}


contract SPCrowdsale is CappedCrowdsale, Pausable {

  uint256 bonus75endAmount;
  uint256 bonus25endAmount;
  uint256 bonus20endAmount;

  function SPCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _presale, uint256 _cap)
    CappedCrowdsale(_cap + _presale)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    // Divide the token sale in bonus brackets
    bonus75endAmount = _presale;
    uint256 oneThird = _cap.div(3);
    bonus25endAmount = bonus75endAmount.add(oneThird);
    bonus20endAmount = bonus25endAmount.add(oneThird);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new PodCoin();
  }

  // Handle double mint and bonus tokens
  function buyTokens(address beneficiary) public payable whenNotPaused {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    // Adjust tokens according to bonus bracket
    uint256 bonusTokens = 0;
    uint256 bonusRemaining = 0;
    uint256 amountRemaining = weiAmount;

    if (amountRemaining > 0 && weiRaised < bonus75endAmount) {
      bonusRemaining = bonus75endAmount - weiRaised;
      if (amountRemaining > bonusRemaining) {
        bonusTokens += bonusRemaining.mul(rate).div(4).mul(3); // 75% bonus
        amountRemaining -= bonusRemaining;
      } else {
        bonusTokens += amountRemaining.mul(rate).div(4).mul(3); // 75% bonus
        amountRemaining = 0;
      }
    }
    if (amountRemaining > 0 && weiRaised < bonus25endAmount) {
      bonusRemaining = bonus25endAmount - weiRaised;
      if (amountRemaining > bonusRemaining) {
        bonusTokens += bonusRemaining.mul(rate).div(4); // 25% bonus
        amountRemaining -= bonusRemaining;
      } else {
        bonusTokens += amountRemaining.mul(rate).div(4); // 25% bonus
        amountRemaining = 0;
      }
    }
    if (weiRaised < bonus20endAmount) {
      // 20% bonus
      bonusRemaining = bonus20endAmount - weiRaised;
      if (amountRemaining > bonusRemaining) {
        bonusTokens += bonusRemaining.mul(rate).div(5); // 20% bonus
        amountRemaining -= bonusRemaining;
      } else {
        bonusTokens += amountRemaining.mul(rate).div(5); // 20% bonus
        amountRemaining = 0;
      }
    }
    if (amountRemaining > 0) {
      bonusTokens += amountRemaining.mul(rate).div(100).mul(15); // 15% bonus
      amountRemaining = 0;
    }
    // Calculate number of PODs to be created
    uint256 tokens = weiAmount.mul(rate).add(bonusTokens);

    // Update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    // For each POD sold, create another for SportsPodium
    token.mint(wallet, tokens);

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

}
