# dev3pack_lisk_summer_bootcamp
Repo for dev3pack lisk bootcamp
The folders in this repo contains my homework from the dev3pack Lisk Summer Bootcamp. Each fold will contain both code and artifacts for review. This file will be updated with inforamtion on each folder

1. Intro to Solidity: The homework was to create a smart contract with the following requirements:
     Use a struct named User Store data in state variables
     Include public getter function
     Validate that user cannot register twice
     Add a view function to fetch user info Track registration timestamp using uint
       Functions: Create register(), updateProfile(), getProfile()
2. Ether Vault: Build a simple Vault system that allows users to deposit and withdraw Ether. Requirements:
     Use a Library for math Emit an Event when a user deposits or withdraws.
     Use require() or revert() to prevent over-withdrawing ETH or depositing 0 ETH
     Implement Inheritance: Base contract: VaultBase (defines structure and shared logic)
     Derived contract: VaultManager (implements deposit/withdraw functions).
