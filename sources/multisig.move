module multisig::acl_based_mb {
    use std::string::String;
    use std::signer;    
    use std::vector;
    use std::option::{Self, Option};
    use aptos_framework::account;
    use aptos_std::event::{Self, EventHandle};
    use aptos_framework::coin::{Self};

    struct Multisig has key {
        owners: vector<address>,
        threshold: u64,
        resource_cap: account::SignerCapability
    }
    struct Transaction has key {
        type: String,
        accounts: vector<address>,
        data: vector<u8>,
        signers: vector<bool>,
        multisig: address,
        resource_cap: account::SignerCapability
    }
    public entry fun create_multisig(
        account: &signer,
        owners: vector<address>,
        threshold: u64,
        seeds: vector<u8>
    ){
        let account_addr = signer::address_of(account);
        let (multisig, multisig_cap) = account::create_resource_account(account, seeds);
        let multisig_signer_from_cap = account::create_signer_with_capability(&multisig_cap);
        move_to<Multisig>(&multisig_signer_from_cap, Multisig{owners,threshold,resource_cap:multisig_cap});
    }
    public entry fun create_transaction(
        account: &signer,
        type: String,
        accounts: vector<address>,
        data: vector<u8>,
        seeds: vector<u8>,
        multisig: address
    )acquires Multisig{
        let account_addr = signer::address_of(account);
        let (transaction, transaction_cap) = account::create_resource_account(account, seeds);
        let transaction_signer_from_cap = account::create_signer_with_capability(&transaction_cap);
        let multisig_data = borrow_global_mut<Multisig>(multisig);
        // let index = 0;
        // for (signer_index in multisig_data.owners){
        //     if multisig_data.owners[signer_index] == account_addr{
        //         index = signer_index
        //     }
        // }
        let signers = vector::empty<bool>();
        vector::push_back(&mut signers, true);
        move_to<Transaction>(&transaction_signer_from_cap, Transaction{type,accounts,data,signers,multisig,resource_cap:transaction_cap});
    }
    public entry fun execute_transaction(
        account: &signer,
        type: type,
        accounts: vector<address>,
        data: vector<u8>,
        seeds: vector<u8>,
        multisig: address
    ){
        type(accounts,data);
    }
}