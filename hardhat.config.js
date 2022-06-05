require('solidity-coverage')
require('@nomiclabs/hardhat-waffle')
require('dotenv').config()
require('./tasks/tasks')

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.14',
  networks: {
    hardhat: {
    },
    ropstenTest: {
      url: 'https://ropsten.infura.io/v3/14cbbc42687b431c8b963469d0a5fdb6',
      accounts: [process.env.RINKEBY_PRIVAT_KEY]

    }

  }
}
