# Smart Contract-based Organization (on Ethereum)

SMBO is an initiative to have an open-source smart contract that can be duplicated and run on the Ethereum to replace the memorandum and enforcement of company's policy. In the beginning, this contract's goal is to help startups easily select from templates and manage their company's shares, debts, and shareholders. In the future, the goal is for this contract to be used by parties to share ownership of virtual anything, and vote on how those shares are dispersed. 

The first use cases are:

  - Startup creation and share issuance
  - Votes on share transfers between new and existing members or employee stock option plans.
  - Manage loans and organization can take on, so they can be later converted to equity, resold to another entity, or pay-off.

Please send pull requests to the develop branch, as all pull requests to master will be ignored. Additionally, this README will be updated with Ether bounties to hit certain mission-critical goals; however, don't let that stop you from contributing in other areas. All contributors will receive some share of ownership in the release version of a future web-based application. That share of ownership will be issued through this very contract and the beginning amount will be issued, at first, at the discretion of this author when it is created, then managed via the smart contract. We are open to many ideas to how to implement this, so please post any issues.



### Version
0.0.1

### Tech

SCBO uses a number of open source projects to work properly:

* Solidity - smart contract language for Ethereum
More to come when we move past just the smart-contract-side of this


### Installation
(Better documentation coming soon on running this contract), for now just a note (please contribute!):
Deploying the contract on the testnet, through ethereum wallet, or on a private-net is your best bet to trying it. Add the source code, and have ethereum wallet compile it, and then open it on the contracts tab.
First thing you should do is add 2 owners. Give one ~30 shares and the other ~40 shares. Then activate the setnewsharevalue function by sending from both addresses, and for price send something like 3 for the first argument, and just szabo for the 2nd string argument. Once you send that exact argument from both addresses, it should change the share price, it did for me.


License
----

MIT


**Free Software, Hell Yeah!**
