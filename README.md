#  BDG Daily Wallet - Swift

A bitcoin wallet app template for iOS. 

Intended as a good starting point for new bitcoin wallet projects.
This is WORK IN PROGRESS.

### Dependencies
- LDK Node - to handle both onchain and lightning bitcoin needs
- KeychainAccess - to store encrypted data in keychain

### Implemented features
- Create new LDK Node started from mnemonic (12 words, no pass-phrase)
- Backup encrypted mnemonic info to iOS keychain
- Start from said backup if present

### Wallet types
Currently only supports single key HD segwit/bech32 wallets with BIP84 derivation paths
Descriptors created by the app will look like: `wpkh([extended private key]/84'/1'/0'/0/*)` 

### Backup schemes
Currently only encrypted backup to the iOS keychain is supported. At the moment it uses a static encryption key.
