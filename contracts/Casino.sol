pragma solidity ^0.4.18;

contract Casino {
   address owner;
   uint public minimumBet;
   uint public totalBet;
   uint public numberOfBets;
   uint public maxAmountOfBets = 3;
   uint public minBetNumber = 1;
   uint public maxBetNumber = 10;
   uint public prevWinningNumber = 0;
   address[] players;
   uint[] activeNumbers;

   event UserBet(address indexed user, uint indexed number, uint value);
   event WinningNumberSelected(uint number, uint prizeTotal);
   event DistributePrize(address indexed to, uint value);

   struct Player {
     uint amountBet;
     uint numberSelected;
   }

   mapping(address => Player) playerInfo;
   mapping(uint => uint) amountBetPerNumber;

   function Casino(uint _minimumBet) public {
      owner = msg.sender;
      minBetNumber = 1;
      maxBetNumber = 10;
      if(_minimumBet != 0) minimumBet = _minimumBet;
   }

   function kill() public {
      if(msg.sender == owner)
         selfdestruct(owner);
   }

   function bet(uint number) public payable {
     assert(checkPlayerExists(msg.sender) == false);
     assert(number>=minBetNumber && number<=maxBetNumber);
     assert(msg.value >= minimumBet);

     playerInfo[msg.sender].amountBet = msg.value;
     playerInfo[msg.sender].numberSelected = number;
     totalBet += msg.value;
     players.push(msg.sender);
     if(amountBetPerNumber[number] == 0) {
       activeNumbers.push(number);
     }
     amountBetPerNumber[number] += msg.value;
     numberOfBets++;
     UserBet(msg.sender, number, msg.value);

     if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   // Generates a random number between min and max possible numbers
   // TODO: Very primitive random number generator. Make it more secure
   function generateNumberWinner() private {
     uint random_num = block.number;
     uint winning_index = random_num % activeNumbers.length;
     uint winning_num = activeNumbers[winning_index];
     WinningNumberSelected(winning_num, totalBet);
     distributePrizes(winning_num);
   }

   function distributePrizes(uint winningNumber) private {
     for(uint i = 0; i < players.length; i++){
       address playerAddress = players[i];
       if(playerInfo[playerAddress].numberSelected == winningNumber) {
         uint amountBet = playerInfo[playerAddress].amountBet;
         uint totalBetOnWinner = amountBetPerNumber[winningNumber];
         uint winnings = (amountBet * totalBet) / totalBetOnWinner;
         playerAddress.transfer(winnings);
         DistributePrize(playerAddress, winnings);
       }
       delete playerInfo[playerAddress];
     }
     resetData();
     prevWinningNumber = winningNumber;
   }

   function resetData() private {
     players.length = 0;
     activeNumbers.length = 0;
     totalBet = 0;
     numberOfBets = 0;
     // reset all bet counters to 0
     for(uint j = minBetNumber; j <= maxBetNumber; j++){
       amountBetPerNumber[j] = 0;
     }
   }

   function checkPlayerExists(address player) public constant returns(bool){
     for(uint i = 0; i < players.length; i++) {
       if(players[i] == player) return true;
     }
     return false;
   }

   // Fallback function in case someone sends ether to the contract so it
   // doesn't get lost
   function() public payable {}
}
