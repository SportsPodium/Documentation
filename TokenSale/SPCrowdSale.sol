pragma solidity ^0.4.13;

import './PodCoin.sol';
import '../node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';


contract SPCrowdsale is CappedCrowdsale, Pausable {

  uint256 bonus75endAmount;
  uint256 bonus25endAmount;
  uint256 bonus20endAmount;

  function SPCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet,
    uint256 _presale, uint256 _cap, address _steemitWallet, uint256 _steemitTokens)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap + _presale)
  {
    // Divide the token sale in bonus brackets
    bonus75endAmount = _presale;
    uint256 oneThird = _cap.div(3);
    bonus25endAmount = bonus75endAmount.add(oneThird);
    bonus20endAmount = bonus25endAmount.add(oneThird);

    // Load the Steemit presale wallet with PODs so that the purchasers can claim them later
    token.mint(_steemitWallet, _steemitTokens);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new PodCoin(); // Just a named MintableToken
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
      bonusTokens += amountRemaining.mul(rate).div(100).mul(115); // 15% bonus
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