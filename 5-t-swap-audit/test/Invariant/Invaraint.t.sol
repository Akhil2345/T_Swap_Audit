// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import { Handler } from "./Handler.t.sol";
contract Invariant is StdInvariant, Test{
    ERC20Mock poolToken; 
    ERC20Mock weth ; // We are creating tokesn based on PoolFactory.sol
    // Because in the pool these are the two tokens defined 
     // We are going to need the contrcacts 
    PoolFactory factory ;
    TSwapPool pool; //PoolTken / WETH, // We are creating 1 pool just now 
    ERC20Mock tokenB;
    int256 constant STARTING_X = 100e18; // starting ERC20
    int256 constant STARTING_Y = 50e18; // starting WETH
    uint256 constant FEE = 997e15; //
    int256 constant MATH_PRECISION = 1e18;
    TSwapPoolHandler handler;
    Handler handler;



    function setUp() public{
        weth = new ERC20Mock();
        poolToken  = new ERC20Mock();
        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(poolToken)));
        // Create the initial x & y values for the pool
        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));
        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);
        pool.deposit(uint256(STARTING_Y), uint256(STARTING_Y), uint256(STARTING_X), uint64(block.timestamp));
        handler = new Handler(pool);
        bytes4[] memory selectors = new bytes[](2);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.swaapPoolTokenForWethBasedOnOutputWeth.selector;
        targetSelector(FuzzSelector({addr : address(handler), selectors: selectors}));
        targetContract(address(handler));

        
    }
    function statefulFuzz_constantProductFormulaStaysTheSame() public{
        assertEq(handler.actualDeltaX(), handler.expectedDeltaX());

        
    }
}