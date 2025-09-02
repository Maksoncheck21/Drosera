# GasChangeTrap — Drosera Trap SERGEANT

## Objective
GasChangeTrap is a Drosera trap designed to monitor Ethereum gas price anomalies (EIP-1559 `baseFee`) across consecutive blocks. The trap uses the standard `collect()` / `shouldRespond()` interface and triggers a response whenever the base fee changes by **5% or more**. Alerts are handled by a separate contract, `LogGasAlertReceiver`, which logs anomalies for monitoring purposes.

## Problem
Ethereum users, DAOs, and DeFi protocols rely on predictable gas fees for operations. Sudden changes in `baseFee` can indicate network congestion, frontrunning risks, or abnormal activity affecting transaction costs.

## Solution
GasChangeTrap collects the current base fee, compares it to the previous block, and signals an anomaly if the deviation exceeds the predefined threshold. This allows automated monitoring of gas price fluctuations, provides logging for analysis, and can be integrated into wider automation or alerting systems.

## Trap Logic Summary

### Trap Contract: GasPriceAnomalyTrap.sol
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}

contract GasPriceAnomalyTrap is ITrap {
    uint256 public constant thresholdPercent = 5; // 5%

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        if (previous == 0) return (false, "Previous value is zero");

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percent = (diff * 100) / previous;

        if (percent >= thresholdPercent) {
            return (true, "");
        }

        return (false, "");
    }
}
```
## Response Contract: LogGasAlertReceiver.sol
```solidity//
 SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogGasAlertReceiver {
    event GasAlert(uint256 currentBaseFee, string message);

    function logGasAnomaly(uint256 currentBaseFee, string calldata message) external {
        emit GasAlert(currentBaseFee, message);
    }
}
```
## Benefits
1. Detects suspicious or abnormal changes in Ethereum base fee.

2. Provides automated logging of gas anomalies.

3. Integrates with automation or monitoring logic for proactive response.

## Deployment & Setup
1. Deploy both contracts to an Ethereum network using your preferred tool (e.g., Foundry or Hardhat).

2. Connect the trap to the response contract in drosera.toml:
```solidity
[traps.gastrap]
path = "out/GasPriceAnomalyTrap.sol/GasPriceAnomalyTrap.json"
response_contract = "<LogGasAlertReceiver address>"
response_function = "logGasAnomaly(uint256,string)"
```
3. Apply changes in Drosera to start monitoring blocks in real time.

## Testing
1. Simulate blocks with changing baseFee on a testnet.

2. Wait 1–3 blocks.

3. Observe logs from Drosera operator: shouldRespond='true' appears in logs and dashboard.

## Extensions & Improvements
1. Dynamic threshold adjustment for anomaly detection.

2. Monitor additional network metrics (tip cap, gas usage).

3. Chain multiple traps for comprehensive network surveillance.

Author & Date
Created: September 2, 2025

Author: Maksoncheck21

Telegram: @Makson_check

Discord: makson_check
