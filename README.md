# IGC Blockchain

## Mục tiêu dự án

Dự án này cung cấp một mạng blockchain private (mạng nội bộ, có kiểm soát thành viên) chạy local bằng Hyperledger Besu theo cơ chế QBFT.

Dùng để:

- Học cách vận hành blockchain permissioned (mạng chỉ node được cấp quyền mới tham gia)
- Làm môi trường dev/test cho backend web3
- Deploy và kiểm thử smart contract trước khi đưa lên môi trường cao hơn

## Bức tranh tổng thể

Hệ thống có 3 lớp:

- Lớp hạ tầng blockchain: 4 node Besu chạy bằng Docker Compose
- Lớp smart contract: thư mục `smart-contracts/` dùng Hardhat
- Lớp ứng dụng ngoài: backend/web/mobile gọi JSON-RPC vào Besu

## Cấu trúc thư mục chính

```text
IGC-Blockchain/
|-- config/
|   `-- qbftConfigFile.json
|-- scripts/
|   |-- generate-network.sh
|   `-- network-status.sh
|-- smart-contracts/
|   |-- contracts/
|   |-- scripts/
|   `-- test/
|-- docs/
|   |-- 01-jargon.md
|   |-- 02-besu-chi-tiet.md
|   |-- 03-khai-niem-co-ban.md
|   |-- 04-khoi-dong-mang.md
|   |-- 05-smart-contracts.md
|   `-- 06-faq-troubleshooting.md
|-- docker-compose.yml
|-- start.bat
`-- .env
```

## Vai trò từng phần

- `config/qbftConfigFile.json`: thông số genesis (file khởi tạo chain) cho QBFT.
- `scripts/generate-network.sh`: sinh network files + key cho node.
- `docker-compose.yml`: chạy 4 node Besu, map cổng RPC/P2P.
- `scripts/network-status.sh`: kiểm tra block height, peer, block production.
- `start.bat`: menu thao tác nhanh trên Windows.
- `smart-contracts/`: code Solidity, test/deploy bằng Hardhat.

## Luồng dữ liệu mức cao

1. App ngoài gửi transaction qua RPC (thường vào node-4).
2. Node nhận tx, phát tán qua P2P (giao tiếp node với node).
3. Validator chạy QBFT để đồng thuận.
4. Block mới được tạo và đồng bộ sang các node khác.

Lưu ý: app ngoài không gọi lệnh "tạo block"; app chỉ gửi transaction. Việc đóng block thuộc consensus (đồng thuận) của validator.

## Tài liệu cho người mới

- `docs/README.md`: lộ trình đọc
- `docs/01-jargon.md`: từ điển thuật ngữ
- `docs/02-besu-chi-tiet.md`: Besu chi tiết
