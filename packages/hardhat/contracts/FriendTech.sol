// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20 token standard from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FriendTech is ERC20 {
    address public owner;

    // Mapping to store the share price set by each address
    mapping(address => uint256) private sharePrice;
    // Mapping to store the total shares owned by each address
    mapping(address => uint256) public totalShares;
    
    // New mapping to store the voting power of each address
    mapping(address => uint256) public votingPower;

    constructor() ERC20("FriendTech", "FTK") {
        owner = msg.sender;
    }

    // Function to set the share price for an address
    function setSharePrice(uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        sharePrice[msg.sender] = price;
    }

    // Function to get the share price of an address
    function getSharePrice(address user) public view returns (uint256) {
        return sharePrice[user];
    }

    // Function to set the total shares owned by an address
    function setTotalShares(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        totalShares[msg.sender] = amount;
    }

    // Function to get the total shares owned by an address
    function getTotalShares(address user) public view returns (uint256) {
        return totalShares[user];
    }

    // Function to allow buying shares from another address
    function buyShares(address seller, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[seller] >= amount, "Seller does not have enough shares");
        require(sharePrice[seller] <= msg.value, "Insufficient payment");

        totalShares[seller] -= amount;
        totalShares[msg.sender] += amount;

        // Calculate the amount of tokens to mint based on the share price
        uint256 tokensToMint = (msg.value * 10**decimals()) / sharePrice[seller];
        _mint(msg.sender, tokensToMint);
    }

    // Function to allow selling shares to another address
    function sellShares(address buyer, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[buyer] += amount;

        // Calculate the amount of tokens to burn based on the share price
        uint256 tokensToBurn = (amount * sharePrice[msg.sender]) / 10**decimals();
        _burn(msg.sender, tokensToBurn);
        payable(buyer).transfer(tokensToBurn);
    }

    // Function to transfer shares to another address
    function transferShares(address to, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[to] += amount;

        // Transfer the corresponding amount of tokens
        _transfer(msg.sender, to, amount);
    }
}