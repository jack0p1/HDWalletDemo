# HDWalletDemo
A simple demo app to manage your HD wallet on the Ethereum blockchain and demonstrate some basic concepts about the Web3. The project utilizes the following frameworks installed via SPM:
- [web3swift](https://github.com/skywinder/web3swift)
- [XCoordinator](https://github.com/quickbirdstudios/XCoordinator)
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift).

The app lets you create a new HD wallet or import an existing one using your secret seed phrase. It checks wallet balance in a few supported crypto coins and tokens. It also allows to create/import new accounts as well as sending transactions in supported coins/tokens.

Currently supported coins/tokens:
- ETH (Ropsten network)
- LINK (Rinkeby network)
- GIBO (Ropsten network)

## Usage
Clone the repo and open the *HDWalletDemo.xcodeproj* file. Please make sure to include a *Constants.swift* file of your own in the project that contains an endpoint to an Ethereum node (like Infura):
```swift
enum Constants {
    static let ropstenEndpoint = "YOUR ROPSTEN ENDPOINT URL"
    static let rinkebyEndpoint = "YOUR RINKEBY ENDPOINT URL"
}
```
Run the project.
