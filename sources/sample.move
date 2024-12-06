module sample_coin::coin {

    use std::option;
    use sui::coin::{Self};
    use sui::transfer;
    use sui::tx_context::{TxContext};

    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields
    struct COIN has drop {}

    /// Register the COIN currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: COIN, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,
            9,
            b"SAMPLE", // symbol
            b"Sample Coin", // name
            b"A test coin",
            option::none(), // temporary url
            ctx
            );


        transfer::public_freeze_object(metadata);
        
        let amount = 1_000_000_000_000_000_000; // maximum supply of coins that will ever be in circulation (1 billion)
        let recipient = @0x8e78225d72b1d7b1f63e5e9f88f09b12ca66c84e2fc8b91fc10f6a0c51230615; // mint recipient address

        coin::mint_and_transfer(&mut treasury_cap, amount, recipient, ctx);

        transfer::public_transfer(treasury_cap, @0) // no one can mint new tokens 

    }

}