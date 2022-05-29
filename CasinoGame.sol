// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

contract CasinoGame {
    mapping (uint => mapping (address => uint256)) public rooms;
    mapping (uint =>  address[]) public roomAddresses;

    uint public currentRoomId;
    uint8 public personCounter;
    uint8 constant public roomUsersCount = 4;

    event GameOver(uint roomId, address winner, uint256 amount);

    function startingPlay() payable public {
        require (msg.value >= 0.025 ether, "For be in game you need to pay 0.025 ether.");

        addUserToGame(msg.sender, msg.value);

        if (personCounter == roomUsersCount - 1) {
            uint ramdomNumber = this.random(roomAddresses[currentRoomId].length);
            address payable selectedAddress = payable(roomAddresses[currentRoomId][ramdomNumber]);
            uint256 thisContractBalance = this.getBalance(address(this));

            emit GameOver(currentRoomId, selectedAddress, thisContractBalance);
            selectedAddress.transfer(thisContractBalance);
            startNewgame();
        } else {
            personCounter += 1;
        }
    }

    function addUserToGame(address userAddress, uint value) private {
        if (rooms[currentRoomId][userAddress] == 0) {
            rooms[currentRoomId][userAddress] = value;
        } else {
            rooms[currentRoomId][userAddress] += value;
        }

        roomAddresses[currentRoomId].push(userAddress);
    }

    function random(uint limit) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % limit;
    }

    function getAddressesInRoom(uint8 roomId) public view returns (address[] memory) {
        return roomAddresses[roomId];
    }

    function getBalance(address userAddress) public view returns (uint256) {
        return userAddress.balance;
    }

    function startNewgame() private {
        currentRoomId += 1;
        personCounter = 0;
    }
}
