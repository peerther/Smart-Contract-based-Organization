contract Company {
    
    //TODO: Add comments
    //TODO: Standardize styling a littlbe better, whether to pre_ every local variable or only arguments
    address owner;
    address treasureChest;
    
    uint public commonShares;
    uint public preferredShares;
    uint public sharePrice;
    uint public majority;
    
    string[] public articles;
    
    modifier onlyowner { if (msg.sender == owner) _ }
    
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
    }
        //Voting["NewSharePrice"][500] = 
    struct Voting {
        mapping(address => VoterAddress) ownerAddress;
        address[] ownersVotedArray;
    }
    struct VotesFor {
        uint sharesVotingFor;
    }
    struct VoterAddress {
        bool alreadyVoted;
        uint lastVotedSubject; //helps clear votes for any previous amounts/subjects pertaining to this vote type
        mapping(uint => VotesFor) subject;
    }
    
    
    //votingFor["newShareValue"].subject[newValue].sharesVotingFor;
    CompanyIdentity public companyId;
    ShareOwner[] shareOwnership;
    mapping (string => Voting) votingFor;
    
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
    
    function issueShares(address _ownerAddress, bool _isCommon, uint _amount) {
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
    
    function removeSharesFromOwner(address _ownerAddress, uint _numSharesToRemove) {
        //The one calling to revoke the shares of a certain shareholder
        uint _revokerIndex = checkIfAlreadyOwner(msg.sender);
        uint _revokerShares = shareOwnership[_revokerIndex].isCommonShare[true].sharesOwned;
        
        //The shareholder that is to have their shares revoked
        uint _ownerIndex = checkIfAlreadyOwner(_ownerAddress);
        uint _ownerShares = shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned;
        
        //Check if revoker is valid common share owner, and if revokee actually has any common shares to be revoked
        if (_revokerIndex > shareOwnership.length ||
        _ownerIndex > shareOwnership.length ||
        _revokerShares == 0 ||
        _ownerShares == 0 ||
        _ownerShares < _numSharesToRemove)
            throw;
            
        uint _sharesForRevocation = shareOwnership[_ownerIndex].sharesToRevoke[_numSharesToRemove].sharesVotingFor;
        _sharesForRevocation += _revokerShares;
        
        
        //Vote
        if ((_sharesForRevocation * 100) / commonShares >= majority) {
            //clear any votes for shares to be removed at this amount or higher, in case this owner is issued more common shares
            for (uint i = _numSharesToRemove; i <= _ownerShares; i++) {
                //MUST TEST, THEORETICALLY SHOULD WORK
                delete shareOwnership[_ownerIndex].sharesToRevoke[i];
            } 
           shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned -= _numSharesToRemove;
            
        }
        
    }
    
    //Formerly createOwner, renamed for a better fit name, if I understood explanation correctly
    //Allows for chest address to be changed.
    function changeChestAddress(address _chest) {
        treasureChest = _chest;
    }

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
    
    //getPendingShares.
    
    function nameCompany(string _name) onlyowner {
        companyId.name = _name;
        companyId.nameSetTime = now;
    }
    
    function saveArticles(string _article) {
        articles.push(_article);
    }
    
    function setNewShareValue(uint _val, string _unit) {
        uint _newValue = _val;
        
        //Ensures minimum of a szabo is suggested as share value
        if (stringsEqual(_unit, "szabo"))
            _newValue *= 1 szabo;
        else if (stringsEqual(_unit, "finney"))
            _newValue *= 1 finney;
        else if (stringsEqual(_unit, "ether"))
            _newValue *= 1 ether;
        else
            throw;
            
        uint _ownerIndex = checkIfAlreadyOwner(msg.sender);
        if (_ownerIndex > shareOwnership.length)
            throw;
    
        uint _commonShares = shareOwnership[_ownerIndex].isCommonShare[true].sharesOwned;
        if (_commonShares == 0)
            throw;
            
        uint _lastVoted = votingFor["newShareValue"].ownerAddress[msg.sender].lastVotedSubject;
        if (votingFor["newShareValue"].ownerAddress[msg.sender].alreadyVoted) {
            if (_lastVoted > 0) 
                votingFor["newShareValue"].ownerAddress[msg.sender].subject[_lastVoted].sharesVotingFor = 0;
        }
        else {
            votingFor["newShareValue"].ownersVotedArray.push(msg.sender);
            votingFor["newShareValue"].ownerAddress[msg.sender].alreadyVoted = true;
        }
            
        votingFor["newShareValue"].ownerAddress[msg.sender].subject[_newValue].sharesVotingFor += _commonShares;
        _lastVoted = _newValue;
        
        //checkIfAlreadyOnVoterList(msg.sender, votingFor["newShareValue"]); prolly not needed
        
        if ((countVotes("newShareValue", _newValue)* 100) / commonShares >= majority)
            sharePrice = _newValue;
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
        for (uint i = 0; i < _voterArray.length; i++) {
            _voteTotal += votingFor[_votingFor].ownerAddress[_voterArray[i]].subject[_subject].sharesVotingFor;
        }
        return _voteTotal;
    }

	function stringsEqual(string _a, string _b) private returns (bool) {
	    if (sha3(_a) == sha3(_b))
	        return true;
	    else
	        return false;
	}
}
