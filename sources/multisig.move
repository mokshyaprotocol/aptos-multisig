module multisig::acl_based_mb {
    // use std::string::String;
    use std::signer;    
    use std::vector;
    use aptos_framework::account;
    // use aptos_std::event::{Self, EventHandle};
    // use aptos_framework::coin::{Self};

    const INVALID_SIGNER: u64 = 0;

    struct Multisig has key,store {
        owners: vector<address>,
        threshold: u64,
        // resource_cap: account::SignerCapability
    }
    struct ResourceInfo has key {
        source: address,
        resource_cap: account::SignerCapability
    }
    struct Transaction has key {
        // type: String,
        // accounts: vector<address>,
        // data: vector<u8>,
        amount: u64,
        signers: vector<bool>,
        // multisig: address,
        resource_cap: account::SignerCapability
    }
    public entry fun create_multisig(
        account: &signer,
        owners: vector<address>,
        threshold: u64,
        seeds: vector<u8>
    ){
        // let account_addr = signer::address_of(account);
        let (_multisig, multisig_cap) = account::create_resource_account(account, seeds);
        let multisig_signer_from_cap = account::create_signer_with_capability(&multisig_cap);
        let multisig_data = Multisig{
                    owners,
                    threshold
        };
        move_to(account, multisig_data);
        move_to<ResourceInfo>(&multisig_signer_from_cap, ResourceInfo{resource_cap: multisig_cap, source: signer::address_of(account)});
    }
    public entry fun create_transaction(
        account: &signer,
        // accounts: vector<address>,
        amount: u64,
        seeds: vector<u8>,
        // multisig: address
    )acquires Multisig{
        let account_addr = signer::address_of(account);
        let (_transaction, transaction_cap) = account::create_resource_account(account, seeds);
        let transaction_signer_from_cap = account::create_signer_with_capability(&transaction_cap);
        // let length_of_schedule =  vector::length(&release_amounts);
        let multisig_data = borrow_global_mut<Multisig>(account_addr);
        // let owners_length = vector::length(&multisig_data.owners);
        let signers = vector::empty<bool>();
        // let i = 0;
        multisig_data.threshold=1;
        // while ( i < owners_length){
            // let tmp = *vector::borrow(&multisig_data.owners,i);
            // if (tmp == account_addr){
            // vector::push_back(&mut signers, true);
            // };
            // else {
            //     vector::push_back(&mut signers, false);
            // };
            // i=i+1;
        // };
        move_to<Transaction>(&transaction_signer_from_cap, Transaction{amount,signers,resource_cap:transaction_cap});
    }
    #[test(ownerA = @0xa11ce, ownerB = @0xb0b)]
    fun create_multisig_test(
        ownerA: signer,
        ownerB: signer,
    ){
        let ownerA_addr = signer::address_of(&ownerA);
        let ownerB_addr = signer::address_of(&ownerB);
        aptos_framework::account::create_account_for_test(ownerA_addr);
        aptos_framework::account::create_account_for_test(ownerB_addr);
        let owners = vector<address>[ownerA_addr,ownerB_addr];
        let threshold=2;
        create_multisig(&ownerA,owners,threshold,b"1bc");
        // let xxxx = account::create_resource_address(&ownerA_addr, b"1bc");

        // let amount = 10;
        // create_transaction(&ownerA,amount,b"1bd",xxxx);
        // let multisig_data = borrow_global_mut<Multisig>(multisig);
        // assert!(multisig_data.threshold == 2, INVALID_SIGNER);
    }
    #[test(ownerA = @0xa11ce)]
    fun create_transaction_test(
        ownerA: signer,
        // ownerB: address,
    )acquires Multisig{
        // let ownerA_addr = signer::address_of(&ownerA);
        let amount = 10;
        // let signers = vector<bool>[true];
        // let multisig = account::create_resource_address(&ownerA_addr, b"1bc");
        create_transaction(
            &ownerA,
            amount,
            b"1bd",
            // multisig
        );
        // let transaction = account::create_resource_address(&ownerA_addr, b"01");
        //  let multisig_data = borrow_global_mut<Transaction>(transaction);
        // assert!(multisig_data.signers == signers, INVALID_SIGNER);
    }
}