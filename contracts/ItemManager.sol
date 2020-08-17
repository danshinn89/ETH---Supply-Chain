pragma solidity >=0.6.0;

import "./Ownable.sol";
import "./Item.sol";

/*
Title: Supply Chain
Descritopn: Create items and track their status in the supply chain. 
Each item created is given a seperate address that allows for easy user purchases.
*/
contract ItemManager is Ownable {
    
    //check state of item
    enum SupplyChainState{Created, Paid, Delivered}
    
    //keeps all the information of item crated
    struct S_Item {
        Item _item;
        string _identifier;
        uint _itemPrice;
        ItemManager.SupplyChainState _state;
        
    }
    
    mapping (uint => S_Item) public items;

    //index of item created
    uint itemIndex;
    
    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);
    
    //Allows owner to create a new Item and define the price of item
    function createItem(string memory _identifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier; // Item name
        items[itemIndex]._itemPrice = _itemPrice; //Item Price
        items[itemIndex]._state = SupplyChainState.Created; //Item state "Created"
        
        //call event SupplyChainStep
        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(item));
        
        itemIndex++;
             
    }
    //Triggers payment for item if customer sends correct amount for item.
    function triggerPayment(uint _itemIndex) public payable {
        require(items[_itemIndex]._itemPrice == msg.value, "Only full payments accepted");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item is further in the chain");
        
        items[_itemIndex]._state = SupplyChainState.Paid;
        
        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
        
        
    }
    
    //only owner is allowed to trigger item delivered after payment has been made.
    function triggerDelivery(uint _itemIndex) public onlyOwner {
    require(items[_itemIndex]._state == SupplyChainState.Created, "Item is further in the chain");
    items[_itemIndex]._state = SupplyChainState.Paid;
       
        
        
    }
}