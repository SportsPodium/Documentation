# POD Vesting and Governance

This document explains the process around vesting of POD tokens and voting rights for SportsPodium.

Vested PODs start earning a network fee 7 days after being vested and can influence network governance after 90 days. Vested PODs can be divested at any time with immediate effect.

## Smart Contract

The entire process for vesting and distribution of allocated PODs from the vesting pool is handled by one smart contract. The contract records the vesting address, the number of pods and the date vesting started per deposit. Deposit transactions are delete upon withdrawal.

``` solidity
function deposit(uint256 value) public returns (bool);
function withdraw(uint256 value) public returns (bool);
function distribute(uint256 value) public returns (bool);
function total() public view returns (uint256);
function vestedTotal() public view returns (uint256);
function votingTotal() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function vestedBalanceOf(address who) public view returns (uint256);
function votingBalanceOf(address who) public view returns (uint256);
```

## Vesting PODs

In order to make vested PODs, you have to call the `deposit` function on the contract. This function will transfer PODs from the calling address to the contract. The date will be indexed against all deposits.

## Divesting PODs

Vested tokens can be withdrawn at any time by calling the `withdraw` function. The latest deposits will be withdrawn first up to the oldest deposit until the request is filled.

## Paying out network fees

5% of all `network income` and `POD emission` will be distributed to vested POD holders. Network income is dependent on specific deals with partners and network service providers (e.g. advertisers) while POD emission will be based on network usage and growth - up to a maximum of 10% per month.

The `distribute` function can be called from any wallet or contract that holds POD tokens that needs to be allocated to vested POD holders. This will typically be executed once per day, but can be called at any time and interval that makes sense for the specific scenario. The function will first determine the current distribution of vested PODs (tokens that have been in the contract for 7 days or more) and then allocate the specified tokens accordingly.

## Voting on network governance

Vested PODs will earn the right to vote after 90 days in the contract. Any external function can query the contract for the current distribution of voting rights by calling `votingBalanceOf` for a specific address and comparing that to `votingTotal` PODs.