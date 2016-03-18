contract Company {
    
    address public owner;
    address public treasureChest;
    
    uint public commonShares;
    uint public preferredShares;
    uint public sharePrice;
    uint public majority;
    
    string[] public articles;
    
    struct CompanyIdentity {
        string name;
        uint creationTime;
        uint nameSetTime;
    }
    struct ShareOwner {
        address ownerAddress;
        string ownerName;
        mapping(bool => ShareTypeOwnership) isCommonShare; //Note, true will show any common shares owned, and false denotes preferred
        mapping(uint => VotesFor) sharesToRevoke;
    }
    struct ShareTypeOwnership {
        uint sharesOwned;
        uint sharesForSale;
        uint shareSalePrice;
    }
        //Voting["NewSharePrice"][500] = 
    struct Voting {
        mapping(address => VoterAddress) ownerAddress;
        address[] ownersVotedArray;
    }
    struct VotesFor {
        uint sharesVotingFor;
    }    
    struct VotesTarget {
        mapping(uint => VotesFor) subject;
    }
    struct VoterAddress {
        bool alreadyVoted;
        uint lastVotedSubject; //helps clear votes for any previous amounts/subjects pertaining to this vote type
        mapping(uint => VotesFor) subject;
        mapping(address => VotesTarget) target;
    }
    
    //votingFor["newShareValue"].subject[newValue].sharesVotingFor;
    CompanyIdentity public companyId;
    ShareOwner[] shareOwnership;
    mapping (string => Voting) votingFor;
    
    modifier onlyowner { 
        if (msg.sender != owner)
            throw;
        else  _ }
    
    modifier onlyCommonOwner { 
        uint _ownerIndex = checkIfAlreadyOwner(msg.sender);
        if (shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned > 0) _ 
    }
    
    modifier onlyShareholder { 
        if (checkIfAlreadyOwner(msg.sender) <= shareOwnership.length && 
        shareOwnership.length > 0) _
    }
    
    function Company() {
        owner = msg.sender;
        companyId = CompanyIdentity ("New Company", now, now);
        createStartup();
        //could specifiy an address, but simply using the owner is SAFER, to avoid invalid addresses or typos
        changeChestAddress(owner);
    }
    
    //Fallback - refund any ether sent, that doesn't do some sort of function call
    function () {
        throw;
    }
    
    function createStartup() private{
        commonShares = 100;
        preferredShares = 100;
        sharePrice = 100 szabo; //0.0001 ether
        majority = 50; //in % format can set custom percent for majority vote requirement
    }
    
    function issueShares(address _ownerAddress, bool _isCommon, uint _amount) onlyowner {
        uint availableSharesOfType = _isCommon ? commonShares : preferredShares;
        availableSharesOfType -= checkTotalIssuedShares(_isCommon);
        if(availableSharesOfType < _amount)
            throw;
        
        uint _ownerIndex = checkIfAlreadyOwner(_ownerAddress);
        if (_ownerIndex == shareOwnership.length)
            throw;
            
        shareOwnership[_ownerIndex].isCommonShare[_isCommon].sharesOwned += _amount;
    }
    
    //must add before you can issue
    function addOwner(address _ownerAddress, string _ownerName) {
        uint _ownerIndex = checkIfAlreadyOwner(_ownerAddress);
        if (_ownerIndex <= shareOwnership.length && shareOwnership.length > 0)
            throw;
            
        shareOwnership.push(ShareOwner(_ownerAddress, _ownerName));
    }
    //Not Working again...???
    //TODO: REMOVE ANY VOTES AND ANY INSUFFICIENT SHARES FOR SALE and TRANSFERS
    //Only allows common shares to be removed by common owners
    function removeSharesFromOwner(address _ownerAddress, uint _numSharesToRemove) onlyCommonOwner {
        //The one calling to revoke the shares of a certain shareholder
        uint _revokerIndex = checkIfAlreadyOwner(msg.sender);
        uint _revokerShares = shareOwnership[_revokerIndex].isCommonShare[true].sharesOwned;
        
        //The shareholder that is to have their shares revoked
        uint _ownerIndex = checkIfAlreadyOwner(_ownerAddress);
        uint _ownerShares = shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned;
        
        //Check if revoker is valid common share owner, and if revokee actually has any common shares to be revoked
        if ( _ownerIndex > shareOwnership.length ||
        _ownerShares == 0 ||
        _ownerShares < _numSharesToRemove || 
        _numSharesToRemove < 1)
            throw;
            
        if (votingFor["revokeShares"].ownerAddress[msg.sender].alreadyVoted) {
            uint _lastVoted = votingFor["revokeShares"].ownerAddress[msg.sender].lastVotedSubject;
            if (_lastVoted > 0)
                delete votingFor["revokeShares"].ownerAddress[msg.sender].target[_ownerAddress].subject[_lastVoted];
        }
        else {
            votingFor["revokeShares"].ownersVotedArray.push(msg.sender);
            votingFor["revokeShares"].ownerAddress[msg.sender].alreadyVoted = true;
        }
        
        votingFor["revokeShares"].ownerAddress[msg.sender].target[_ownerAddress].subject[_numSharesToRemove].sharesVotingFor = _revokerShares;
        votingFor["revokeShares"].ownerAddress[msg.sender].lastVotedSubject = _numSharesToRemove;
        
        uint _totalVotes = countTargetedVotes("revokeShares", _numSharesToRemove, _ownerAddress);

        if ((_totalVotes * 100) / commonShares >= majority)
            shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned -= _numSharesToRemove;
    }
    
    function forwardToChest(uint _amt) {
        safeSend(treasureChest, _amt);
    }
    
    //Formerly createOwner, renamed for a better fit name, if I understood explanation correctly
    //Allows for chest address to be changed.
    function changeChestAddress(address _chest) onlyowner {
        treasureChest = _chest;
    }
    
    //getPendingShares.
    
    function nameCompany(string _name) onlyowner {
        companyId.name = _name;
        companyId.nameSetTime = now;
    }
    
    function saveArticles(string _article) onlyCommonOwner {
        articles.push(_article);
    }
    
    function setNewShareValue(uint _val, string _unit) onlyCommonOwner {
        uint _newValue = _val * currencyCheck(_unit);
            
        uint _ownerIndex = checkIfAlreadyOwner(msg.sender);
    
        uint _commonShares = shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned;
            
        uint _lastVoted = votingFor["newShareValue"].ownerAddress[msg.sender].lastVotedSubject;
        
        if (votingFor["newShareValue"].ownerAddress[msg.sender].alreadyVoted) {
            if (_lastVoted > 0) 
                votingFor["newShareValue"].ownerAddress[msg.sender].subject[_lastVoted].sharesVotingFor = 0;
        }
        else {
            votingFor["newShareValue"].ownersVotedArray.push(msg.sender);
            votingFor["newShareValue"].ownerAddress[msg.sender].alreadyVoted = true;
        }
        
        /*if(countVotes("newShareValue", _newValue) == 0) 
            votingFor["newShareValue"].proposalSubject.push(_newValue);*/
            
        votingFor["newShareValue"].ownerAddress[msg.sender].subject[_newValue].sharesVotingFor += _commonShares;
        votingFor["newShareValue"].ownerAddress[msg.sender].lastVotedSubject = _newValue;
        
        //checkIfAlreadyOnVoterList(msg.sender, votingFor["newShareValue"]); prolly not needed
        
        if ((countVotes("newShareValue", _newValue)* 100) / commonShares >= majority)
            sharePrice = _newValue;
    }
    
    function setSharesForSale(uint _amt, uint _price, string _unit, bool _isCommon) onlyShareholder {
        //Turn this into a modifier for optimization
        uint _ownerIndex = checkIfAlreadyOwner(msg.sender);
        
        uint _sellerShares = shareOwnership[_ownerIndex].isCommonShare[_isCommon].sharesOwned;
        uint _ownersSharesForSale = shareOwnership[_ownerIndex].isCommonShare[_isCommon].sharesForSale;
        
        //check owner has enough shares to sell
        if (_sellerShares == 0 || (_sellerShares - _ownersSharesForSale) < _amt)
            throw;
        
        uint _newValue = _price * currencyCheck(_unit);
        
        //shareOwnership[_ownerIndex].isCommonShare[_isCommon].sharesForSale = _amt;
        shareOwnership[_ownerIndex].isCommonShare[_isCommon].sharesForSale = _amt;
        shareOwnership[_ownerIndex].isCommonShare[_isCommon].shareSalePrice = _newValue;
        
        //Remove shareholders votes once trade executed DONE in buy portion
    }
    
    //TODO: FIX unable to buy when only 1 owner in array, must be checkownership function issue FIXED
    //price must be included to ensure buyer gets the shares for price they are expecting
    function buySharesFrom(string _buyerName,
        address _sellerAddress, 
        uint _amt, 
        uint _price, 
        string _unit, 
        bool _isCommon) 
    {
        
        uint _sellerIndex = checkIfAlreadyOwner(_sellerAddress);
        uint _formattedPrice = _price * currencyCheck(_unit);
        uint _transactionValue = _amt * _formattedPrice;
        ShareTypeOwnership _sellerShortcut = shareOwnership[_sellerIndex].isCommonShare[_isCommon];
        
        //Check if shares of type are for sale by this seller at requested price
        if (_sellerShortcut.sharesForSale < _amt || 
        _sellerShortcut.shareSalePrice != _formattedPrice ||
        msg.value < _transactionValue)
            throw;
            
        //Exchange approved, add buyer to owners if needed.
        uint _buyerIndex = checkIfAlreadyOwner(msg.sender);
        if (_buyerIndex > shareOwnership.length) {
            shareOwnership.push(ShareOwner(msg.sender, _buyerName));
            _buyerIndex -= 1;
        }

        

        
        
        //ORDER MAY BE IMPORTANT HERE, TEST!!!!!
        shareOwnership[_sellerIndex].isCommonShare[_isCommon].sharesForSale -= _amt;
        shareOwnership[_sellerIndex].isCommonShare[_isCommon].sharesOwned -= _amt;
        //IF THESE WERE COMMON SHARES, MUST REMOVE ANY VOTES THEY ARE AFFECTING, INCLUDING SHARE REVOCATION
        if (_isCommon)
            delete votingFor["newShareValue"].ownerAddress[_sellerAddress];
        //Need to debug, in case there's multiple calls at same time, there may be collisions between buyers
        shareOwnership[_buyerIndex].isCommonShare[_isCommon].sharesOwned += _amt;
        
        //After shares change hands, send funds
        safeSend(_sellerAddress, _transactionValue);
        //Refund any remainder back to buyer
        safeSend(msg.sender, msg.value - _transactionValue); //change send

        
    }
    
    //TODO Fix needs to be able to transfer irregardless of shareownership size, currently only works if more than 2, maybe, recheck
    function transferShares (address _receiver, uint _amt, bool _isCommon) onlyShareholder {
        uint _senderIndex = checkIfAlreadyOwner(msg.sender);
        
        uint _receiverIndex = checkIfAlreadyOwner(_receiver);
        if (_receiverIndex > shareOwnership.length)
            shareOwnership.push(ShareOwner(_receiver, ""));
            
        //Ensure the shares being sent aren't for sale on market already, to avoid transferring shares while still
        //having them on the exchange
        uint _sharesForSale = shareOwnership[_senderIndex].isCommonShare[_isCommon].sharesForSale;
        uint _sharesOwned = shareOwnership[_senderIndex].isCommonShare[_isCommon].sharesOwned;
        if (_sharesOwned - _sharesForSale < _amt)
            throw;
        
        shareOwnership[_senderIndex].isCommonShare[_isCommon].sharesForSale -= _amt;
        shareOwnership[_senderIndex].isCommonShare[_isCommon].sharesOwned -= _amt;
        
        if (_isCommon)
            delete votingFor["newShareValue"].ownerAddress[msg.sender];
            
        shareOwnership[_receiverIndex].isCommonShare[_isCommon].sharesOwned += _amt;
    }
    
    //Constant functions
    function getCurrentShares(uint shareHolderIndex) constant returns (
        address _ownerAddress, 
        string _ownerName, 
        uint _commonShares, 
        uint _preferredShares)
    {
        if (shareHolderIndex <= shareOwnership.length) {
            _ownerAddress = shareOwnership[shareHolderIndex].ownerAddress;
            _ownerName = shareOwnership[shareHolderIndex].ownerName;
            _commonShares = shareOwnership[shareHolderIndex].isCommonShare[true].sharesOwned;
            _preferredShares =  shareOwnership[shareHolderIndex].isCommonShare[false].sharesOwned;
        }
    }
    
    function getSharesForSale(address _sellerAddress) constant returns (
        string _ownerName, 
        uint _commonSharesSelling,
        uint _commonSharesPrice,
        uint _preferredSharesSelling,
        uint _preferredSharesPrice)
    {
        uint _sellerIndex = checkIfAlreadyOwner(_sellerAddress);
        
        _ownerName = shareOwnership[_sellerIndex].ownerName;

        _commonSharesSelling = shareOwnership[_sellerIndex].isCommonShare[true].sharesForSale;
        _commonSharesPrice = shareOwnership[_sellerIndex].isCommonShare[true].shareSalePrice;
        
        _preferredSharesSelling = shareOwnership[_sellerIndex].isCommonShare[false].sharesForSale;
        _preferredSharesPrice = shareOwnership[_sellerIndex].isCommonShare[false].shareSalePrice;
    }
    
    //The following are helper functions
    function checkIfAlreadyOwner(address _ownerAddress) private returns (uint) {
        if (shareOwnership.length == 0)
            return 0;
        for (uint i = 0; i < shareOwnership.length; i++) {
            if (shareOwnership[i].ownerAddress == _ownerAddress) {
                return i;
            }
        }
        return shareOwnership.length + 1;
    }
    
    //deprecated?
    function checkIfAlreadyOnVoterList(address _ownerAddress, Voting _voterArray) private returns (bool) {
        for (uint i = 0; i < _voterArray.ownersVotedArray.length; i++) {
            if (_ownerAddress == _voterArray.ownersVotedArray[i] )
                return true;
        }
        return false;
    }
    
    function checkTotalIssuedShares(bool _isCommon) private returns (uint) {
        uint _shareTypeTotal = 0;
        for (uint i = 0; i < shareOwnership.length; i++) {
            _shareTypeTotal += shareOwnership[i].isCommonShare[_isCommon].sharesOwned;
        }
        return _shareTypeTotal;
    }
    
    function countVotes(string _votingFor, uint _subject) private returns (uint) {
        uint _voteTotal = 0;
        address[] _voterArray = votingFor[_votingFor].ownersVotedArray;
        for (uint i = 0; i < _voterArray.length; i++)
            _voteTotal += votingFor[_votingFor].ownerAddress[_voterArray[i]].subject[_subject].sharesVotingFor;
        
        return _voteTotal;
    }
    
    function countTargetedVotes(string _votingFor, uint _subject, address _target) private returns (uint) {
        uint _voteTotal = 0;
        address[] _voterArray = votingFor[_votingFor].ownersVotedArray;
        for (uint i = 0; i < _voterArray.length; i++)
            _voteTotal += votingFor[_votingFor].ownerAddress[_voterArray[i]].target[_target].subject[_subject].sharesVotingFor;
        
        return _voteTotal;
    }
    
    
    function currencyCheck(string _unit) private returns (uint) {
        if (stringsEqual(_unit, "szabo"))
            return 1 szabo;
        else if (stringsEqual(_unit, "finney"))
            return 1 finney;
        else if (stringsEqual(_unit, "ether"))
            return 1 ether;
        else if (stringsEqual(_unit, "wei"))
            return 1 wei;
        else
            throw;
    }

	function stringsEqual(string _a, string _b) private returns (bool) {
	    if (sha3(_a) == sha3(_b))
	        return true;
	    else
	        return false;
	}
	
	//Experimental function to be able to send to contracts with expensive fallback functions
	//Works yay
	function safeSend(address _receiver, uint _amtToSend) private {
	    if (_amtToSend > 0) {
    	    bool success = _receiver.send(_amtToSend);
    	    if (!success) {
    	        _receiver.call.value(_amtToSend);//.gas
    	    }
	    }
	}
	
}
