// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract RealEstate{

     struct property{

         uint256 id;
         string title;
         string location;
         uint256 price;
         address payable owner;
         bool forsale;
     } 

     uint256 public propertyCounter=0;

     mapping(uint256 => property) public properties;

     event properyListed(uint256 propertyid,string title,uint256 price,address owner);

     event propertypurchase(uint256 propertyid,address newowner,uint256 price);

     event Delisted(uint256 propertyid);

     modifier onlypropertyowner(uint256 propertyid){
          require(msg.sender==properties[propertyid].owner,"you are not owner");
          _;
     }

     function listproperty(string memory title,string memory location,uint256 price) public{

         require(price > 0 ,"price must be gretaer than 0");
         propertyCounter++;
         uint256 newpropertyid=propertyCounter;

         properties[newpropertyid]= property({
            
               id:newpropertyid,
               title:title,
               location:location,
               price:price,
               owner:payable(msg.sender),
               forsale:true


         });
         emit properyListed(newpropertyid, title, price,msg.sender);

     }

     function buyproperty(uint256 propertyid) public payable{

            property storage prop= properties[propertyid];
            require(prop.forsale,"property id");
            require(msg.value >= prop.price,"not enough prop");
            address payable seller=prop.owner;

            prop.owner=payable(msg.sender) ;

            prop.forsale=false;
            seller.transfer(msg.value);

            emit propertypurchase(propertyid, msg.sender,msg.value); 
     }

     function relist(uint256 propertyid,uint256 newprice) public onlypropertyowner(propertyid){
         require(newprice > 0,"price required");
         properties[propertyid].price=newprice;
         properties[propertyid].forsale=true; 

     }

    function delist(uint256 propertyid) public onlypropertyowner(propertyid){
          
            properties[propertyid].forsale=false;
            emit Delisted(propertyid);
    }

    function getpropdetails(uint256 propertyid) public view  returns (
            string memory title,
            string memory location,
            uint256 price,
            address owner,
            bool forSale
        )
        {
          property storage prop=properties[propertyid];
          return(prop.title,prop.location,prop.price,prop.owner,prop.forsale);
        }

        function getlist() public view returns(property[] memory){
          uint256 totalProperties=propertyCounter;
          uint256 saleCount=0;

            for (uint256 i = 1; i <= totalProperties; i++) {
            if (properties[i].forsale) {
                saleCount++;
            }
        }

       
        property[] memory propertiesForSale = new property[](saleCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= totalProperties; i++) {
            if (properties[i].forsale) {
                propertiesForSale[index] = properties[i];
                index++;
            }
        }

        return propertiesForSale;
    
        }


}