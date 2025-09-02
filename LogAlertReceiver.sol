// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogGasAlertReceiver {
    event GasAlert(uint256 currentBaseFee, string message);

    function logGasAnomaly(uint256 currentBaseFee, string calldata message) external {
        emit GasAlert(currentBaseFee, message);
    }
}
