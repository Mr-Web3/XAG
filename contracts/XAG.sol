// SPDX-License-Identifier: MIT

// Website: https://www.silverchads.com/
// Twitter / X: https://t.me/XAGSilverChads
// Telegram: https://t.me/xag_token

// Built by: Decentral Bro's: https://www.decentralbros.xyz/

//  ____       ____       ____        _____       ____       
// /\  _`\    /\  _`\    /\  _`\     /\  __`\    /\  _`\     
// \ \ \/\ \  \ \ \L\ \  \ \ \L\ \   \ \ \/\ \   \ \,\L\_\   
//  \ \ \ \ \  \ \  _ <'  \ \ ,  /    \ \ \ \ \   \/_\__ \   
//   \ \ \_\ \  \ \ \L\ \  \ \ \\ \    \ \ \_\ \    /\ \L\ \ 
//    \ \____/   \ \____/   \ \_\ \_\   \ \_____\   \ `\____\
//     \/___/     \/___/     \/_/\/ /    \/_____/    \/_____/

// 01000100 01000010 01010010 01001111 01010011

pragma solidity ^0.8.20;

//Imports:
//ERC20.sol: This is the OpenZeppelin library for ERC20 token implementation, providing standard token functionalities.
//Ownable.sol: Also from OpenZeppelin, providing ownership control functionalities.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//Contract Variables:
contract XAG is ERC20, Ownable, ReentrancyGuard {
    uint256 public constant TOTAL_SUPPLY = 1 * 10**6 * 10**18;
    uint256 public constant TAX_PERCENTAGE = 1;
    address public taxAddress;
    address public uniswapV2Pair;
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;

    // Mapping for TAX Free wallets:
    mapping(address => bool) public taxFreeAddresses;


    //Constructor:
    //Initializes the contract with the token name "XAG Silver Chads" and symbol "XAG".
    //Mints the total supply of tokens to the contract deployer's address (msg.sender).
    // ERC-20 contract takes in the 
    constructor(address _taxAddress) ERC20("XAG Silver Chads", "XAG") {
        require(_taxAddress != address(0), "Tax address cannot be the zero address.");
        taxAddress = _taxAddress;
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    function setUniswapV2Pair(address _uniswapV2Pair) external onlyOwner nonReentrant {
        uniswapV2Pair = _uniswapV2Pair;
    }
    
    //setRule Function:
    //Allows the owner to set rules such as limiting token holdings and setting Uniswap V2 pair address.
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner nonReentrant {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }

    //_transfer Function (internal):
    //Overrides the _transfer function from ERC20 to implement custom transfer logic.
    //Applies a 1% tax on transfers (except those involving the owner) and sends the tax amount to the taxAddress.
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 transferAmount = amount;

        if (!taxFreeAddresses[sender] && !taxFreeAddresses[recipient]) {
            // Check if transaction involves buy/sell and apply taxes if enabled and applicable
            if ((sender == uniswapV2Pair || recipient == uniswapV2Pair) && sender != owner() && recipient != owner()) {
                uint256 taxAmount = (amount * TAX_PERCENTAGE) / 100;
                transferAmount = amount - taxAmount;

                super._transfer(sender, taxAddress, taxAmount);
            }
        }

        // Apply holding limits if limited is enabled and transaction is a buy (recipient gets the tokens)
        if (limited && recipient == uniswapV2Pair) {
            require(balanceOf(recipient) + transferAmount <= maxHoldingAmount, "Transfer exceeds max holding limit");
            require(balanceOf(recipient) + transferAmount >= minHoldingAmount, "Transfer below min holding limit");
        }

        super._transfer(sender, recipient, transferAmount);
    }

    function setTaxFreeAddress(address _address, bool _isFree) external onlyOwner nonReentrant {
        taxFreeAddresses[_address] = _isFree;
    }

    //updateTAXAddress Function:
    //Allows the owner to update the TAX address.    
    function updateTaxAddress(address _taxAddress) external onlyOwner nonReentrant {
        require(_taxAddress != address(0), "Tax address cannot be the zero address.");
        taxAddress = _taxAddress;
    }

    //getTAXAddress Function:
    //Returns the current TAX wallet address.
    function getTaxAddress() public view returns (address) {
        return taxAddress;
    }
}