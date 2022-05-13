#  BDG Daily Wallet

A bitcoin wallet app template for iOS. 

Intended as a good starting point for starting new bitcoin wallet projects.

### Dependencies
- Bitcoin Development Kit - to interact with the bitcoin blockchain via Electrum or Esplora APIs
- Lightning Development Kit - not yet implemented
- KeychainAccess - to store encrypted data in keychain

### Wallet types
Currently only supports single key HD segwit wallets using the BIP84 derivation path.
Descriptors created by the app will look like: `wpkh([extended private key]/84'/1'/0'/0/*)` 
