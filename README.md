# BDG Daily Wallet - Swift

An open source bitcoin wallet app template for iOS based on the [Daily wallet reference design](https://bitcoin.design/guide/daily-spending-wallet/) from the Bitcoin Design Guide.

You can try a [Testflight version](https://testflight.apple.com/join/1yaYqZzz) of the app, and interact with the faucet over at [MutinyNet](https://faucet.mutinynet.com)

<img width="1397" alt="BDG_paymentscreen" src="https://github.com/bdgwallet/dailywallet/assets/3393669/e7fb6c5c-ce0c-4016-90bd-67d9ab8ffde8">

### Dependencies

- [LDK Node](https://github.com/tnull/ldk-node) - to handle both onchain and lightning bitcoin needs
- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - to store encrypted data in keychain
- [Bitcoin UI](https://github.com/reez/WalletUI) - swift implentation of the [Bitcoin UI Kit](https://www.bitcoinuikit.com)

### Implemented features

- Create new wallet for both onchain and lightning
- Backup encrypted mnemonic to iOS keychain
- Start from said backup if present
- Receive bitcoin onchain
- Receive bitcoin with lightning with JUST-IN-TIME channels provided by LSPS2 provider
- Send bitcoin onchain
- Send bitcoin with lightning

### Known issues / missing features

Please see this [issue that tracks known issues](https://github.com/bdgwallet/dailywallet/issues/18). Comment if you find new ones.

### Backup schemes

Currently only encrypted backup of mnemonic to the iOS keychain is supported. At the moment it uses a static encryption key.
No lightning node data is currently backed up. Deleting the app WILL LEAD TO LOSS OF FUNDS.
