# Drosera
Ethereum gas price anomaly detection (baseFee ≥5% change)
⛽ GasChangeTrap

A set of smart contracts for detecting anomalies in Ethereum gas price (baseFee from EIP-1559).
If the base fee changes by ≥5% between two consecutive blocks, the anomaly is flagged and logged.

📂 Contents

Overview

Contracts

GasPriceAnomalyTrap

LogGasAlertReceiver

How It Works

Deployment

Example Usage

License

📝 Overview

GasChangeTrap provides:

collection of current gas price (block.basefee),

anomaly detection when gas price changes by 5% or more,

logging anomalies into a separate receiver contract (LogGasAlertReceiver).

⚙ Contracts
GasPriceAnomalyTrap

Implements the ITrap interface and performs anomaly detection.

collect() → returns block.basefee as encoded bytes.

shouldRespond(bytes[] calldata data) → takes two values (current and previous baseFee).

If the difference is ≥5% → returns (true, "").

Otherwise → (false, "").

LogGasAlertReceiver

Receiver contract that logs detected anomalies.

Event:

event GasAlert(uint256 currentBaseFee, string message);


Function:

function logGasAnomaly(uint256 currentBaseFee, string calldata message) external;

🔍 How It Works

GasPriceAnomalyTrap.collect() → fetches the current baseFee.

Compares with the previous collected value.

If change ≥5% → anomaly detected.

Calls LogGasAlertReceiver.logGasAnomaly().

Emits a GasAlert event on-chain.

🚀 Deployment
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost

🧩 Example Usage
// Check anomaly
(bool anomaly, ) = gasTrap.shouldRespond(data);
if (anomaly) {
    logReceiver.logGasAnomaly(currentBaseFee, "Gas price anomaly detected");
}

📜 License

MIT License. Free to use and modify.
