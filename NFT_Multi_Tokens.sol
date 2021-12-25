// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract ZOO_Citizen_NFT is ERC721{
    
    using Strings for uint256;
    string public domain; 
    address public owner_NFT;

    address[] public address_Tokens_Array;
    struct TokenPayment{
        address _Address;
        IERC20 _Token;
        bool _status_Buy;
        bool _status_Sell;
        uint _ratio_Buy;
        uint _ratio_Sell;
    }

    mapping(uint256 => TokenPayment) public ListTokensForPayment;
    
    constructor(string memory name, string memory symbol, string memory domainNFT, address[] memory tokenAddress_array) ERC721(name, symbol){
        owner_NFT = msg.sender;
        domain = domainNFT;                  
        for(uint dem=0; dem<tokenAddress_array.length; dem++){
            address_Tokens_Array.push(tokenAddress_array[dem]);
            ListTokensForPayment[dem] = TokenPayment(
                tokenAddress_array[dem],
                IERC20(tokenAddress_array[dem]),
                true,
                true,
                100,
                110
            );
        }
    }
    
    modifier check_Master(){
        require(msg.sender==owner_NFT, "You are not allowed, sorry.");
        _;
    }

    function addNew_Token_for_Payment(address _addressToken, bool _statusBuy, bool _statusSell, uint _ratioBuy, uint _ratioSell) public check_Master{
        address_Tokens_Array.push(_addressToken);
            ListTokensForPayment[address_Tokens_Array.length-1] = TokenPayment(
                _addressToken,
                IERC20(_addressToken),
                _statusBuy,
                _statusSell,
                _ratioBuy,
                _ratioSell
            );
    }

    function update_Token_for_Payment(uint ordering, bool _statusBuy, bool _statusSell, uint _ratioBuy, uint _ratioSell) public check_Master{
            ListTokensForPayment[ordering]._status_Buy = _statusBuy;
            ListTokensForPayment[ordering]._status_Sell = _statusSell;
            ListTokensForPayment[ordering]._ratio_Buy = _ratioBuy;
            ListTokensForPayment[ordering]._ratio_Sell = _ratioSell;
    }

    function getTokensNumber() public view returns(uint){
        return address_Tokens_Array.length;
    }

    function get_Tokens_Detail(uint ordering) public view returns(address, bool, bool, uint, uint){
        return (
            ListTokensForPayment[ordering]._Address,
            ListTokensForPayment[ordering]._status_Buy,
            ListTokensForPayment[ordering]._status_Sell,
            ListTokensForPayment[ordering]._ratio_Buy,
            ListTokensForPayment[ordering]._ratio_Sell
        );
    }

    function mint_Hero_by_Token(uint256 token_ordering, uint256 tokenId) external{
        require(_exists(tokenId), "Sorry, token Id is not availble");
        require(ListTokensForPayment[token_ordering]._status_Buy==true, "Sorry, this token is not allowed to mint hero at this moment");
        require(
            ListTokensForPayment[token_ordering]._Token.allowance(msg.sender, address(this))>=ListTokensForPayment[token_ordering]._ratio_Buy*1, "Sorry, please approve for us to transfer your Token"
        );
        ListTokensForPayment[token_ordering]._Token.transferFrom(msg.sender, address(this), ListTokensForPayment[token_ordering]._ratio_Buy*1);
        _mint(msg.sender, tokenId);
    }



}