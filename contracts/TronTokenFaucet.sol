// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./libraries/ReentrancyGuard.sol";

import "./interfaces/ITRC20.sol";


contract TronTokenFaucet is ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => bool) private _activatedAssets;
    address[] assets;

  
    event AssetAdded(address indexed token);

    function getAssetInfo(address asset) external view returns (string memory, string memory, uint256, uint256)
    {
        ITRC20 token = ITRC20(asset);
        uint256 totalSupply = token.totalSupply();
        uint256 decimals = token.decimals();
        string memory name = token.name();
        string memory symbol = token.symbol();
        return (name, symbol, decimals, totalSupply);
    }

    function addAsset(address asset) external
    {

        ITRC20 token = ITRC20(asset);        
        require(!_activatedAssets[asset],"Asset already added");

        address tokenOwner = token.getOwner();
        require (msg.sender==tokenOwner, "Can only add assets you own");

        _activatedAssets[asset] = true;
        assets.push(asset);
        emit AssetAdded(asset);
    }

    function disburseTokens(uint256 amount, address asset) external nonReentrant
    {
        require(_activatedAssets[asset],"Asset not added to faucet");

        ITRC20 token = ITRC20(asset);
        uint256 balance = token.balanceOf(address(this));

        if(balance < amount){
          token.mint(amount);
        }

        token.transfer(msg.sender,amount);
    }

}
