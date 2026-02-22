# 01. Giới thiệu dự án

## Dự án này là gì?

Đây là một mạng blockchain private chạy bằng Hyperledger Besu theo cơ chế đồng thuận QBFT.

Mạng gồm 4 node:

- Node 1: Validator
- Node 2: Validator
- Node 3: Validator
- Node 4: RPC node (để ứng dụng gọi API)

## Dự án dùng để làm gì?

- Dựng môi trường blockchain local để học và phát triển
- Deploy smart contract để test nghiệp vụ
- Mô phỏng hạ tầng blockchain nội bộ doanh nghiệp

## Thành phần chính

- `docker-compose.yml`: khởi tạo 4 container Besu
- `scripts/generate-network.sh`: sinh genesis và key cho node
- `scripts/network-status.sh`: kiểm tra trạng thái mạng
- `start.bat`: menu thao tác nhanh trên Windows
- `smart-contracts/`: code smart contract (Hardhat)
