// Fund
// Withdraw

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address recentyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(recentyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe With %s", SEND_VALUE);
    }
    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
                vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
                vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {   

    function WithrawFundMe(address recentyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(recentyDeployed)).withdraw();
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        WithrawFundMe(mostRecentDeployment);

    }}
