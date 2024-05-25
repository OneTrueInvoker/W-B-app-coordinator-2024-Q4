// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketSale {
    address public admin;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;
    bool public saleActive;

    mapping(address => uint256) public ticketBalances;

    event TicketsPurchased(address indexed buyer, uint256 amount);
    event Withdrawal(address indexed admin, uint256 amount);
    event SaleStatusChanged(bool newStatus);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor(uint256 _ticketPrice, uint256 _totalTickets) {
        admin = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        saleActive = false;
    }

    function buyTickets(uint256 _amount) public payable {
        require(saleActive, "Ticket sale is not active");
        require(_amount > 0, "You need to buy at least one ticket");
        require(ticketsSold + _amount <= totalTickets, "Not enough tickets left");
        require(msg.value == ticketPrice * _amount, "Incorrect Ether value sent");

        ticketBalances[msg.sender] += _amount;
        ticketsSold += _amount;

        emit TicketsPurchased(msg.sender, _amount);
    }

    function checkTicketBalance() public view returns (uint256) {
        return ticketBalances[msg.sender];
    }

    function setSaleStatus(bool _status) public onlyAdmin {
        saleActive = _status;
        emit SaleStatusChanged(_status);
    }

    function withdraw() public onlyAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");

        payable(admin).transfer(balance);

        emit Withdrawal(admin, balance);
    }

    // Additional features for brownie points
    function ticketsRemaining() public view returns (uint256) {
        return totalTickets - ticketsSold;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}