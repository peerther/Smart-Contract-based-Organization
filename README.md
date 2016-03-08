# Smart Contract-based Organization

SMBO is an initiative to have an open-source smart contract that can be duplicated and run on the Ethereum to replace the memorandum and enforcement of company's policy. In the beginning, this contract's goal is to help startups easily select from templates and manage their company's shares, debts, and shareholders. In the future, the goal is for this contract to be used by parties to share ownership of virtual anything, and vote on how those shares are dispersed. 

The first use cases are:

  - Startup creation and share issuance
  - Votes on share transfers between new and existing members or employee stock option plans.
  - Manage loans and organization can take on, so they can be later converted to equity, resold to another entity, or pay-off.

Please send pull requests to the develop branch, as all pull requests to master will be ignored. Additionally, this README will be updated with Ether bounties to hit certain mission-critical goals; however, don't let that stop you from contributing in other areas. All contributors will receive some share of ownership in the release version of a future web-based application. That share of ownership will be issued through this very contract and the beginning amount will be issued, at first, at the discretion of this author when it is created, then managed via the smart contract. We are open to many ideas to how to implement this, so please post any issues.



This text you see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.

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

change in your file and instantanously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma start
```

### Docker
Dillinger is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 80, so change this within the Dockerfile if necessary. When ready, simply use the Dockerfile to build the image. 

```sh
cd dillinger
docker build -t <youruser>/dillinger:latest .
```
This will create the dillinger image and pull in the necessary dependencies. Once done, run the Docker and map the port to whatever you wish on your host. In this example, we simply map port 80 of the host to port 80 of the Docker (or whatever port was exposed in the Dockerfile):

```sh
docker run -d -p 80:80 --restart="always" <youruser>/dillinger:latest
```

Verify the deployment by navigating to your server address in your preferred browser.

### N|Solid and NGINX

More details coming soon.

#### docker-compose.yml

Change the path for the nginx conf mounting path to your full path, not mine!

### Todos

 - Write Tests
 - Rethink Github Save
 - Add Code Comments
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**
