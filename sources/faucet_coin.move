module faucet_coin::faucet_coin;

use sui::balance::{Self, Balance};
use sui::coin::{Self, TreasuryCap};

/// 代币类型
public struct FAUCET_COIN has drop {}

/// 水龙头对象，存储代币余额
public struct FaucetCoin has key, store {
    id: UID,
    coin: Balance<FAUCET_COIN>,
}

/// 初始化代币和水龙头
fun init(witness: FAUCET_COIN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<FAUCET_COIN>(
        witness,
        6,                              // 小数位数
        b"TC",              // 符号
        b"test_coin",              // 名称
        b"for test",              // 描述
        option::none(),                // 无图标
        ctx
    );
    transfer::public_freeze_object(metadata);       // 冻结元数据
    transfer::public_transfer(treasury_cap, tx_context::sender(ctx)); // 转移 TreasuryCap

    let faucet_coin = FaucetCoin {
        id: object::new(ctx),
        coin: balance::zero(),      // 初始余额为 0
    };
    transfer::public_share_object(faucet_coin);     // 共享水龙头对象
}

/// 管理员填充水龙头
public entry fun mint(
    treasury_cap: &mut TreasuryCap<FAUCET_COIN>,
    wallet: &mut FaucetCoin,
    amount: u64,
    ctx: &mut TxContext
) {
    let coins = coin::mint(treasury_cap, amount, ctx);      // 铸造代币
    balance::join(&mut wallet.coin, coin::into_balance(coins)); // 加入水龙头余额
}

/// 用户从水龙头领取代币
public entry fun faucet(wallet: &mut FaucetCoin, ctx: &mut TxContext) {
    assert!(balance::value(&wallet.coin) >= 10000, 0);       // 检查余额是否足够
    let coin2 = coin::take(&mut wallet.coin, 10000, ctx);    // 领取 0.01 FAUCET_COIN
    transfer::public_transfer(coin2, tx_context::sender(ctx)); // 转移给调用者
}

// package id: 0x8c15848fff170849fa7aec120f05ad90ca2338967b0730ca6091ea94eb24d59e
//treasurycap:0x12fa1f7f538defe2e73ccf5394d81775ca23ca1737c0cc5be635d986bcb2d33f
//owner:0x6b1d06a358a3dbcf61c0f17bfa3813c199c1f23b90f0e8aa7fbfa9e9433c4f9c
// faucet id:0x37a794c2d0b397983c5c763f4471784e28d2456574d719020f211f0454fd93d6

