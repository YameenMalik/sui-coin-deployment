
module sample_coin::coin {

    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields
    struct COIN has drop {}

    /// Maximum supply of coins that will ever be in circulation (1 billion)
    const MAX_SUPPLY: u64 = 1_000_000_000_000_000_000;

    /// Triggered when the more coins than max supply are attempted to be minted
    const EMaxSupplyReached: u64 = 1;

    /// Register the COIN currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: COIN, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,
            6,
            b"SAMPLE", // symbol
            b"Sample Coin", // name
            b"A test coin",
            option::none(), // temporary url
            ctx
            );

        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))

    }

    /// Manager can mint new coins
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<COIN>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        // The total supply can never be > max supply
        let total_supply = coin::total_supply(treasury_cap);
        assert!(total_supply + amount <= MAX_SUPPLY, EMaxSupplyReached);

        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// Manager can burn coins
    public entry fun burn(treasury_cap: &mut TreasuryCap<COIN>, coin: Coin<COIN>) {
        coin::burn(treasury_cap, coin);
    }

}

