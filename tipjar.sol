// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

contract tips {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct Waitress {
        address payable walletAddress; 
        string name;                   
        uint percent;                  
    }

    Waitress[] waitress;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _ ;
    }

    function addtips() payable public {}

    function viewtips() public view returns(uint) {
        return address(this).balance;
    }

    function viewWaitress() public view returns(Waitress[] memory) {
        return waitress;
    }

    function _transferFunds(address payable recipient, uint amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed.");  
    }

    // --- ส่วนที่แก้ไข: เพิ่มการตรวจสอบ Total Percent ---
    function addWaitress(address payable walletAddress, string memory name, uint percent) public onlyOwner {
        uint currentTotalPercent = 0;
        bool waitressExist = false;

        // 1. วนลูปเช็คว่ามีอยู่แล้วไหม และคำนวณเปอร์เซ็นต์รวมปัจจุบัน
        for(uint i = 0; i < waitress.length; i++) {
            if(waitress[i].walletAddress == walletAddress) {
                waitressExist = true;
            }
            currentTotalPercent += waitress[i].percent;
        }

        // 2. ตรวจสอบว่าถ้าเพิ่มไปแล้วจะเกิน 100 หรือไม่
        require(currentTotalPercent + percent <= 100, "Total percent exceeds 100%");
        
        // 3. ตรวจสอบว่าซ้ำหรือไม่
        require(!waitressExist, "Waitress already exists");

        // 4. เพิ่มข้อมูล
        waitress.push(Waitress(walletAddress, name, percent));
    }

    function distributeBalance() public {
        uint totalBalance = address(this).balance;
        require(totalBalance > 0, "No Money");
        
        for(uint j = 0; j < waitress.length; j++) {
            uint distributeAmount = (totalBalance * waitress[j].percent) / 100;
            if (distributeAmount > 0) {
                _transferFunds(waitress[j].walletAddress, distributeAmount);
            }
        }
    }

    function removeWaitress(address walletAddress) public onlyOwner {
        for(uint i = 0; i < waitress.length; i++) {
            if(waitress[i].walletAddress == walletAddress) {
                waitress[i] = waitress[waitress.length - 1];
                waitress.pop();
                break;
            }
        }
    }
}