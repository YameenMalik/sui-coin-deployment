# Sui Coin Deployment
The repo houses sample coin contract for Sui ecosystem and steps on how to deploy it from scratch.


## How To

### Installation
The first order of business is to install sui-cli. There are multiple ways to do it, you can build it from source but the easiest approach is to use `homebrew`
- Install brew if you don't have already using `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Check if you already have sui cli installed using `sui -V`. If not, install it using `bew install sui`. Run `sui -V` again and you should see the version of sui installed `sui 1.xx.x-homebrew`.

### Environment Setup
Next we need to decide, on which chain of Sui we want to deploy our coin contract to. By default sui-cli when installed has a single environment `testnet` in its configuration but you can add an environment of your choice following these steps:

- Add the environment (chain local/testnet/mainnet) to which you want to deploy the token. This can be done using `sui client new-env --alias <ALIAS> --rpc <RPC>`. For testnet do `sui client new-env --alias testnet --rpc https://fullnode.testnet.sui.io:443`. Make sure the alias `testnet` in this example being used is unique and not already existing else you will run into `Environment config with name [testnet] already exists.` error. If you want to know which environments are available run `sui client envs`
- Switch cli to the environment we created in the previous step using `sui client switch --env <ENV-ALIAS>`. For the previously created `testnet` env do `sui client switch --env testnet`

### Deployment wallet
We need to setup an account/wallet that will be used to deploy the coin. This account needs to be funded with SUI tokens to pay for contract deployment gas fee.
- To create a wallet using cli run `sui client new-address <KEY_SCHEME>`. You can chose `secp256k1` or `ED25519` as wallet scheme. The created wallet is stored in sui configs as well as outputted to console. You don't need to save any of the wallet details like its phrase or address as this can be retrieve from sui-cli at any point in time. 
    ```
    myym@Muhammads-MacBook-Pro sui-coin-deployment % sui client new-address secp256k1
    ╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
    │ Created new keypair and saved it to keystore.                                                   │
    ├────────────────┬────────────────────────────────────────────────────────────────────────────────┤
    │ alias          │ heuristic-alexandrite                                                          │
    │ address        │ 0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f             │
    │ keyScheme      │ secp256k1                                                                      │
    │ recoveryPhrase │ forget ### ###### ####### ### #### #### #### #### ####### #### ###             |
    ╰────────────────┴────────────────────────────────────────────────────────────────────────────────╯
    ```
- Next up, you need to make the wallet you want to use for deployment of the coin as the active wallet address on sui-cli. You may have multiple wallets on sui-cli, the one you want to use for deployment, should bet set as active. This can be done using `sui client switch --address <address>`
    ```
    myym@Muhammads-MacBook-Pro sui-coin-deployment % sui client switch --address 0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f

    Active address switched to 0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f
    ```
- Before you can use the active wallet for performing any transactions like deploying the coin contract, you must have it funded with SUI tokens to pay for gas fee. For testnet/localnet, you can use the sui cli faucet to fund the account. For mainnet, you will need to procure SUI from a platform like `Bluefin` and transfer them to your active wallet on sui-cli. To use faucet run:  `sui client faucet --help --address <address>`
    ```
    myym@Muhammads-MacBook-Pro sui-coin-deployment % sui client faucet --address 0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f 

    Request successful. It can take up to 1 minute to get the coin. Run sui client gas to check your gas coins.
    ```


### Coin Contract
On Sui chain, contracts are deployed as packages and each package can have one or more modules. We need to first create the coin contract including a coin module before we can deploy it. A sample coin contract is provided at `/sources/sample.move` that we will be publishing as part of this tutorial. The contract is self explanatory and has some very minimal functions like `mint` and `burn`. When the coin contract will get deployed we will get the following objects:
```
    {
        "Package": "0x9753a815080c9a1a1727b4be9abb509014197e78ae09e33c146c786fac3731e0",
        "UpgradeCap": "0xa1ae1c3345fc64a7086132f8de78aedb25aa5af51cd052ea14ff282b5d36ee64",
        "TreasuryCap": "0x10bec91ee5e8124decfdfdf589cccb78cf8e6e989088b52202cbfe5bb678cedb",
        "CoinMetadata": "0x7fc201551955241d072085b129c43e85ec21cfd617589f29e6d48bcd9229e341",
    }
```
- **Package:** This is the id/address of the deployed contract. Each deployed contract has one.
- **UpgradeCap:** This is the id/address of the upgrade capability object. Each package deployed to Sui has one upgrade capability object. This object is owned by the deployer of the contract upon deployment. This can be transferred to some other account if need be. This object is used to push upgrades to a smart contract on Sui. Only the person holding the upgrade capability object of a package can push upgrades to it.
- **TreasuryCap:** This is the id/address of the treasury capability object. This is particular to our coin contract, not all contracts have a treasury cap. Upon deployment of the coin contract, we transfer the treasury cap object to the deployer. This can be later transfer by the deployer to some other account if need be. Only the holder of treasury cap object can mint/burn coins.
- **CoinMetadata:** This is the id/address of the coin metadata object. This is particular to the our coin contract. This is a shared object that contains the meta data of our coin like its symbol, name and description.

Other then these objects, you need to be aware of the type of your deployed coin. This is important as your coin is known by its type on-chain. The type of a coin is composed of 1) the package id/address 2) the module name 3) Name of the coin. These three are combined to make a coin type which looks like this: `<pkg_address>::<module>::<CoinSymbol>`.

### Deployment
In order to deploy the coin contract first navigate to the directory containing the `Move.toml` and `sources/` of the contract. Once at the right path, you can publish the contract to Sui chain using `sui client publish --json`. The `--json` is optional but it returns the output of a transaction in json format that you can later easily go through. Inside the JSON, you can see the objects that were mutated during the contract deployment:
```
"objectChanges": [
    { //  This the published package/contract id
      "type": "published",
      "packageId": "0x00dc3293a4f7328f911269bad1315b137a59f5415e9479f3d4213358db56ba10", 
      "version": "1",
      "digest": "3f86ioGzPyMvvUvVsnmSNtYhhFF2kGth2zNRzQG3Nxvh",
      "modules": [
        "coin"
      ]
    },
    {
      //  This the published Coin metadata object id
      "type": "created",
      "sender": "0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f",
      "owner": "Immutable",
      "objectType": "0x2::coin::CoinMetadata<0x00dc3293a4f7328f911269bad1315b137a59f5415e9479f3d4213358db56ba10::coin::COIN>", 
      "objectId": "0x267c85ea13a8b1af1b8a755d629ed575e0e509e979f15a02bcd305ff68bc2bfd",
      "version": "236171204",
      "digest": "3uqCydjdcUu2tSfyK2C66TGTFpBcCTM1mrcbYvBebrgD"
    },
    {
      //  This the upgrade capability object object id
      "type": "created",
      "sender": "0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f",
      "owner": {
        "AddressOwner": "0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f"
      },
      "objectType": "0x2::package::UpgradeCap",
      "objectId": "0x831b419f7742776803174b090f8ad44a38a501554ef8c394571d7d37f93911e3",
      "version": "236171204",
      "digest": "6YKhB43oW7LCdmbT4uWbwaf5YLxVkZRTEVraJLsV7n2N"
    },
    {
      //  This the upgrade Treasury cap object id
      "type": "created",
      "sender": "0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f",
      "owner": {
        "AddressOwner": "0x7945bac9edeb5751c29573cebb36b738309d7b857402a1ec42f15bc6acecdf6f"
      },
      "objectType": "0x2::coin::TreasuryCap<0x00dc3293a4f7328f911269bad1315b137a59f5415e9479f3d4213358db56ba10::coin::COIN>",
      "objectId": "0x92589ac0a37a7b7f3fb901bcd90a2ddc2d1b59665d3d002e898290146833f166",
      "version": "236171204",
      "digest": "Ai3RP8uKZDKbqgAtQnr22h6giGqRusZyfa9DxTbQADLA"
    }
  ],
```

You will also find the `digest` at the top of the JSON in this format `FMsqCw7ToeTL5w2UxrimsPURHLkV8WXr5Qgfq9uw3vnS`. You can look this digest up on [sui-scan](https://suiscan.xyz/testnet/tx/FMsqCw7ToeTL5w2UxrimsPURHLkV8WXr5Qgfq9uw3vnS) for easier viewing of the data.


### Minting Coins
Each coin contract has a `mint`  method that take as input:
- **Treasury Cap Object:** This is the prove that the caller has the rights to mint the coins
- **Amount:** The amount to be mined. This should be in correct base. If the decimals supported by coin are 9, then to mint one coin, the amount should be `1e9`.
- **Recipient:** The address of the account that will be receiving the minted coins
- **TxContext:** The context of the caller. This is passed by default to each contract call, we don't need to worry about it. 

To invoke the `mint` method run `sui client call --package <address> --module <name> --function mint --args <args>`.
We need to provide the 3 arguments detailed above in the same order. The mint call will look something like this:
```
sui client call \
--package 0x00dc3293a4f7328f911269bad1315b137a59f5415e9479f3d4213358db56ba10 \
--module coin \
--function mint \
--args 0x92589ac0a37a7b7f3fb901bcd90a2ddc2d1b59665d3d002e898290146833f166 1000000000 0x3a47eb941c01e49a4f68af79d43009771b99d96c92a3ff75a775389e30550adc 
``` 
And this is it! You have deployed a coin on Sui and minted its tokens