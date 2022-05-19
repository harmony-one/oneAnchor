# oneAnchor

OneAnchor is the core technological component of Harmony's Fixed Income platform, a set of tools that will allow $ONE holder to stake their coins directly (i.e., without having to swap them into other assets) from Harmony maintained environments such as 1Wallet and Income Dapp.

OneAnchor handles most of its logic from a set of Smart Contracts that manage all the transactional load, a backend server that acts like a relayer when transctions on Terra Network are required, and a set of applications (web and mobile) that interact directly with the contracts. Also, we use Chainlink Oracles to keep updated information about ONE/UST and aUST/UST pairs.

![alt text](https://bafkreifixudbtfcshtlcm3bzlnybqzd3ybu6lqhfxkzwh4hchirsn3f7uq.ipfs.nftstorage.link/)

### Current Status

#### May 19, 2022

Based on current event this repo has been deprecated

#### May 02, 2022

- Contracts and servers ready for auditing, process will take a few weeks, but they should be ready for open beta before the end of the month. We'll be in private beta until all the security audits are complete.
- INCOME Webapp is ready and will be tested during private beta. Some improvements will be implemented in the next couple weeks.
- 1Wallet team already is working on iOS integration.

### oneAnchor components

* oneAnchor solidity contracts
* hardhat deployment scripts

### server

* oneAnchor bot libraries

Start development environment with `npm run start:dev`

#### web app

* oneAnchor React6 webapp moved to https://github.com/harmony-one/oneAnchor-webapp

#### mobile 

* oneAnchor mobile libraries moved to https://github.com/harmony-one/oneAnchor-mobile
