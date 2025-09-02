GasChangeTrap — Drosera Trap SERGEANT
Objective

Create a deployable Drosera trap that:

Monitors Ethereum gas price anomalies (EIP-1559 baseFee) across blocks,

Uses the standard collect() / shouldRespond() interface,

Triggers a response when the base fee changes by ≥5%,

Integrates with a separate alert contract to handle responses (LogGasAlertReceiver).

Problem

Ethereum users, DAOs, and DeFi protocols rely on predictable gas fees for operations. Sudden changes in baseFee can indicate network congestion, frontrunning risks, or abnormal activity affecting transaction costs.

Solution

Monitor the Ethereum base fee across consecutive blocks and trigger an alert if the change exceeds a defined threshold (5%). Alerts are logged via a dedicated receiver contract.

Trap Logic Summary
Trap Contract: GasPriceAnomalyTrap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

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

Response Contract: LogGasAlertReceiver.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogGasAlertReceiver {
    event GasAlert(uint256 currentBaseFee, string message);

    function logGasAnomaly(uint256 currentBaseFee, string calldata message) external {
        emit GasAlert(currentBaseFee, message);
    }
}

What It Solves

Detects suspicious or abnormal changes in Ethereum base fee,

Provides automated logging of gas anomalies,

Can integrate with automation or monitoring logic, e.g., alerting operators during high volatility.

Deployment & Setup Instructions
1. Deploy Contracts

Example using Foundry:

forge create src/GasPriceAnomalyTrap.sol:GasPriceAnomalyTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...

forge create src/LogGasAlertReceiver.sol:LogGasAlertReceiver \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...

2. Update drosera.toml
[traps.gastrap]
path = "out/GasPriceAnomalyTrap.sol/GasPriceAnomalyTrap.json"
response_contract = "<LogGasAlertReceiver address>"
response_function = "logGasAnomaly(uint256,string)"

3. Apply changes
DROSERA_PRIVATE_KEY=0x... drosera apply
{F13A1A68-C0D0-4DFE-AF0B-03BA506B3899}

Testing the Trap

Simulate blocks with changing baseFee on a testnet.

Wait 1–3 blocks.

Observe logs from Drosera operator:

shouldRespond='true' appears in logs and dashboard.

Extensions & Improvements

Allow dynamic threshold for anomaly detection,

Track other network metrics such as gas usage or tip cap,

Chain multiple traps using a unified collector.

Date & Author

First created: September 2, 2025

Author: Maksoncheck21

Telegram: @Maksonchek21

Discord: maksonchek21#0001
