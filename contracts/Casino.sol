pragma solidity ^0.4.18;

contract Casino {
   address owner;
   uint public minimumBet;
   uint public totalBet;
   uint public numberOfBets;
   uint public maxAmountOfBets = 7;
   uint public minBetNumber = 1;
   uint public maxBetNumber = 10;
   uint public prevWinningNumber = 0;
   address[] players;

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
   } // Lets a user bet on a number between 1 and 10
   function bet(uint number) public payable {
     assert(checkPlayerExists(msg.sender) == false);
     assert(number>=minBetNumber && number<=maxBetNumber);
     assert(msg.value >= minimumBet);

     playerInfo[msg.sender].amountBet = msg.value;
     playerInfo[msg.sender].numberSelected = number;
     totalBet += msg.value;
     players.push(msg.sender);
     amountBetPerNumber[number] += msg.value;
     numberOfBets++;

     if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   // Generates a random number between 1 and 10
   // TODO: Very primitive random number generator. Make it more secure
   function generateNumberWinner() private {
     uint random_num = block.number % 10 + 1;
     uint winning_num = pickWinningNum(random_num);
     distributePrizes(winning_num);
   }

   // Pick a winning number that was bet on
   // NOTE: Very inefficient when the bet numbers have a big range
   function pickWinningNum(uint random_num) private constant returns(uint){
     uint winning_num = 0;
     uint index = 0;
     uint possibleNumbers = maxBetNumber - minBetNumber + 1;
     while(random_num > 0) {
       if(amountBetPerNumber[index] != 0) {
         winning_num = index;
         random_num--;
       }
       index = (index + 1) % possibleNumbers;
     }
     return winning_num + 1;
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
