// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CoinContract.sol";

contract AssetContract is ERC721 , Ownable {

  CoinContract public coinContract;

  mapping(address => uint256) public sharesAllotted;  

 mapping(uint256 => address) public sharesByValue;  

 mapping(address => uint256) public rentPercentage; 

  mapping(uint256 => RealEstate) public realEstates;

  address public propertyOwner;
  uint256 public nextRealEstateId;
  uint256 public rentPerMonth;
  uint256 public sharePrice;

  address[] public shareholders;
  uint256[] public sharesDeclared;
  uint256[] public totalShares;

  struct RealEstate {
        string name;
        string location;
        uint256 price;
        address currentOwner;
        bool isRegistered;
  
    }

 constructor(address _coinContract,string memory _name, string memory _location, uint256 _realWorldPrice) ERC721("Property", "PRP") Ownable(msg.sender) {
    coinContract = CoinContract(_coinContract);
    propertyOwner = msg.sender;
    realEstates[nextRealEstateId] = RealEstate({
            name: _name,
            location: _location,
            price: _realWorldPrice,
            currentOwner: propertyOwner,
            isRegistered: true
        });
        nextRealEstateId++;
      shareholders.push(propertyOwner);
      sharesAllotted[propertyOwner] = 100;
      totalShares.push(100);

      rentPerMonth = 10 * (10**16);
      sharePrice = 1 * (10**coinContract.decimals());
      // initial 100 tokens minting
      coinContract.mintToken(propertyOwner,100);

   }


 function getRealEstateDetails(uint256 tokenId)
        external
        view
        returns (
            string memory propertyName,
            string memory propertyLocation,
            uint256 propertyPrice,
            address currentPropertyOwner
        )
    {
        RealEstate storage property = realEstates[tokenId];
        return (property.name, property.location, property.price, property.currentOwner);
    }


      function declareShares(uint256 shareValue)  external  onlyOwner{
        uint256 sum = 0;
        for (uint256 i = 0; i < sharesDeclared.length; i++) {
            sum += sharesDeclared[i];
        }
        require(sum + shareValue <= 100, "Shares exceed the limit");
      
        bool needPop = false;
        require(totalShares.length>0, "Index out of bounds");
        for(uint256 i = 0; i < totalShares.length; i++){
           if(totalShares[i] == sharesAllotted[propertyOwner]){
                needPop = true;
            }
            if (needPop && i < totalShares.length - 1) {
                totalShares[i] = totalShares[i + 1];
            }
        }
        if(needPop == true){
            totalShares.pop();
        }
        totalShares.push(shareValue);
        totalShares.push(sharesAllotted[propertyOwner]-shareValue);
        sharesDeclared.push(shareValue);

      }

      // Event to log the transfer
       event TransferEvent(address indexed from, address indexed to, uint256 value);

       function buyShares(uint256 shareValue)  external payable {

    uint256 sharesPurchased;
     for (uint256 i = 0; i < sharesDeclared.length; i++) {
            if (sharesDeclared[i] == shareValue) {
                 sharesAllotted[msg.sender] = shareValue;
                 sharesPurchased += shareValue;
                 sharesByValue[shareValue] = msg.sender;
                 sharesAllotted[propertyOwner]=100 - sharesPurchased;
                 sharesByValue[100 - sharesPurchased]=propertyOwner;


                 address payable recipient = payable(propertyOwner);
                 require(msg.value == shareValue * (10**16), "Incorrect Ether amount sent");
                 recipient.transfer(msg.value);
                 // Emit the event
                 emit Transfer(address(this), recipient, msg.value);
                
                 coinContract.transferToken(propertyOwner,msg.sender,shareValue);
            }
            else{
                 require(sharesDeclared[i] != shareValue,"Share value not found");
            }
        }


      }

        function getShareDetails(address account)  external view returns(uint256){
    
          return (sharesAllotted[account]);

         }
         function declareRent(uint256 amount) onlyOwner external returns(uint256){
    
         rentPerMonth = amount;
         return rentPerMonth;

         }
         
       

    //     function calculatePercentages(uint256 months,uint256 amount)  payable {
    //     uint256 itemCount = totalShares.length;
    //     uint256 rentAmount = rentPerMonth * months;
    //     require(msg.value == rentAmount, "Incorrect Ether amount sent");
    //     for (uint256 i = 0; i < itemCount; i++) {
    //         rentPercentage[sharesByValue[totalShares[i]]] = (amount *totalShares[i])/100;
    //         address payable recipient = payable(sharesByValue[totalShares[i]]);
    //         recipient.transfer((amount *totalShares[i])/100);
    //     }
    // }

         function payRent(uint256 months)  external payable returns(uint256){
        uint256 itemCount = totalShares.length;
        uint256 rentAmount = rentPerMonth * months;
        require(msg.value == rentAmount, "Incorrect Ether amount sent");
        for (uint256 i = 0; i < itemCount; i++) {
            rentPercentage[sharesByValue[totalShares[i]]] = (msg.value *totalShares[i])/100;
            address payable recipient = payable(sharesByValue[totalShares[i]]);
            recipient.transfer((msg.value *totalShares[i])/100);
        }
          // calculatePercentages(months,msg.value);
          return months;
         }

         function getRentStats(address account) public view returns(uint256){

           return rentPercentage[account];
         }

           function collectCoins(address account) external payable returns(uint256){

           uint256 toCollect = sharesAllotted[account];
           coinContract.transferToken(account,propertyOwner,toCollect);
           return toCollect;

         }

         function withdrawTokens(address shareHolder) external payable onlyOwner{
           coinContract.transferToken(shareHolder,propertyOwner, sharesAllotted[shareHolder]);

         }
      }   