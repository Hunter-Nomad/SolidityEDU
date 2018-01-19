pragma solidity ^0.4.0;

// enum struc event
contract MyContract{
    
    address owner; // адрес владельца контракта
    uint indexUsers; // индекс пользователей 
    
    // структура пользователей в контракте
    struct Users {
        address user; // адрес пользователя
        uint balance; // баланс на пользователя 
        OwnerLevel ownerLevel; // уровень прав пользователя
    }
    
    mapping (address => Users) balances; // мапинг пользователей
    
    enum OwnerLevel{USER, MANAGER, ADMIN} OwnerLevel ol; // список прав пользователей
    OwnerLevel constant defaultUSER = OwnerLevel.USER; // инициализация пользователя по умолчанию
    
    function MyContract() payable{
        indexUsers++;
        owner = msg.sender;
        balances[owner] = Users(owner, msg.value, OwnerLevel.ADMIN); // инициализация прав владельца контракта
    }
    
    // модификатор проверки наличия пользователя в базе balances
    modifier isUser{
        require(msg.sender == balances[msg.sender].user);
        _;
    }
    
    // модификатор проверки наличия пользователя в базе balance и подлинности его как менеджера
    modifier isManager(){
        require(msg.sender == balances[msg.sender].user && balances[msg.sender].ownerLevel == OwnerLevel.MANAGER);
        _;
    }
    
    // модификатор проверки подлинности владельца
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    } 
    
    // добавлене пользователя в базу
    function setUser() payable returns(bool){
        require(msg.sender != balances[msg.sender].user && msg.value > 0);
        indexUsers++;
        balances[msg.sender] = Users(msg.sender, msg.value, defaultUSER);
        return true;    
    }
    
    // чтение пользователем личного баланса
    function getUserBalance() isUser returns(uint){
        return balances[msg.sender].balance;
    }
    
    
    /////////////////////// админ зона)))
    // изменение прав пользователя
    function setOwnerLevel(address a, OwnerLevel level) onlyOwner returns(bool){
        require(a == balances[a].user); 
        balances[a].ownerLevel = level;
        return true;
    }
    
    function getOwnerLevel(address a) onlyOwner returns(OwnerLevel){
        return balances[a].ownerLevel;
    }
    
    // просмотр баланса владельца контракта только от имени владельца контракта
    function getBalanceOwner() onlyOwner returns (uint) {
        return this.balance;
    }
    
    // удалени контракта
    function killContract(address _send) onlyOwner{
         if(_send == 0x0){
            suicide(owner);
         } else {
             suicide(_send);
         }
    }
}
