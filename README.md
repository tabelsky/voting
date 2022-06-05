# Voting

This project is intented as a solution for cryptonacademy's trial.

Commands:

```shell
npx hardhat test    // run tests
npx hardhat coverage    // check coverage
npx hardhat check   // lint contract
npx eslint <filename>   // lint js code

npx hardhat run --network ropstenTest  scripts/deploy.js    // deploy to test network

npx hardhat createVote [--contract <contract address>]  // create a vote  round [on specified contract address]
npx hardhat vote  [--contract <>] --vote-id <id of a vote round>  --candidate <candidate address>  [--ammount <donation value in ETH>]  // vote for candidate
npx hardhat voteInfo [--contract <>] --vote-id <>   // get info about a vote round
npx hardhat finish --vote-id <> // vinish a vote round
npx hardhat withdrawal  // withdrawal available balance
```

<br> .env file must store:

```env
RINKEBY_PRIVAT_KEY='...'
```
