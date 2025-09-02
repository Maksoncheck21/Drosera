// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}

contract GasPriceAnomalyTrap is ITrap {
    uint256 public constant thresholdPercent = 5; // 5%

    // Собираем текущую цену газа (EIP-1559 baseFee)
    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee);
    }

    // Проверяем, изменился ли baseFee на >=5%
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
