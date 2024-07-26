// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import{Test , console2} from "../forge-std/Test.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";

contract Handler is Test{
    TswapPool pool;
    ERC20Mock weth;
    ERC20Mock poolToken ;
    address liquidityProvider = makeAddr("lp");
    address swapper = makeAddr("swapper");
     // Ghost variables 
     uint256 startingY; 
     uint256 startingX;
     uint256  public expectedDeltaX;
     uint256  public expectedDeltaY;
     int256 public actualDeltaX;
     int256  public actualDeltaY;
    constructor(TSwapPool _pool){
        pool= _pool;
        weth = ERC20(_pool.getWeth());
        poolToken = ERC20(_pool.getPoolToken());
        //Deposit , swap exact output
    }
    function swaapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public {
        outputWeth = bount(outputWeth, pool.getMinimumWethDepositAmount(), type(uint64).max);
        if(outputWeth >= weth.balanceOf(address(pool))) {
            return ;
        }
        uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(outputWeth , poolToken.balanceOf(address(pool)), weth.balanceOf(address(pool)));
        if(poolTokenAmount > type(uint64).max){
            return;
        }
        startingY = int256(weth.balancOf(address(pool)));
        StartingX = int256(weth.balancOf(address(pool)));
        expectedDeltaY = int256(-1)*int256(wethAmount);
        // We will be loosing weth and then Expected DeltaX , will be gaining 
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(poolTokenAmount));
        if(poolToken.balanceOf(swapper) < poolTokenAmount){
            poolToken.mint(swapper , poolTokenAmount - poolToken.balanceOf(swapper)+1);

        }
        //Actual Swap 
        vm.startPrank(swapper);
        poolToken.approve(address(pool), type(uint256).max);
        pool.swapExactOutput(poolToken, weth , outputWeth, uint64(block.timestamp));
        vm.stopPrank(); // We have done the swap now 
        //actual 
        uint256 endingY= weth.balanceOf(address(pool));
        uint256 endingX = poolToken.balanceOf(address(pool));
        actualDeltaX = int256(endingY)-int256(startinhY);
        actualDeltaY = int256(endingX)-int256(startingX);

    }   
    function deposit(uint256 wethAmount) public{
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        wethAmount  = bound(wethAmount, minWeth, type(uint64).max);
        startingY = int256(weth.balancOf(address(this)));
        StartingX = int256(weth.balancOf(address(this)));
        expectedDeltaY = int256(wethAmount);
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(wethAmount));
        //deposit 
        vm.startPrank(liquidityProvider);
        weth.mint(liquidityProvider , wethAmount);
        poolToken.mint(liquidityProvide ,uint256( expectedDeltaX));
        weth.approve(address(pool), type(uint256).max);
        poolToken.approve(address(pool), type(uint256).max);
        pool.deposit(wethAmount, 0, uint256(expectedDeltaX), uint64(block.timestamp));
        vm.stopPrank();
        //Actual 
        uint256 endingY= weth.balanceOf(address(this));
        uint256 endingX = poolToken.balanceOf(address(this));
        actualDeltaX = int256(endingY)-int256(startinhY);
        actualDeltaY = int256(endingX)-int256(startingX);

    }
}
