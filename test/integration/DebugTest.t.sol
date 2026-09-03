// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract DebugTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
    }

    function testDebugBalance() public {
        console.log("Test contract balance:", address(this).balance);

        FundFundMe fundFundMe = new FundFundMe();
        console.log("FundFundMe balance before:", address(fundFundMe).balance);
        console.log("FundMe balance before:", address(fundMe).balance);

        fundFundMe.fundFundMe(address(fundMe));

        console.log("FundFundMe balance after:", address(fundFundMe).balance);
        console.log("FundMe balance after:", address(fundMe).balance);
    }
}
