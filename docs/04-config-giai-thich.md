# 04. Giải thích config của project

Nếu gặp thuật ngữ lạ, xem: `docs/01-jargon.md`.

## Nhóm config quan trọng

Project này có 3 lớp cấu hình chính:

- `config/qbftConfigFile.json`: cấu hình gốc để generate network.
- `.env`: biến môi trường cho `docker-compose.yml`.
- `docker-compose.yml`: cấu hình runtime cho từng node Besu.

## `config/qbftConfigFile.json`

File này định nghĩa thông số genesis và số lượng node cần tạo.

Các trường đáng chú ý:

- `chainId: 1337`: định danh chain để tránh replay transaction.
- `qbft.blockperiodseconds: 2`: mục tiêu 2 giây/block.
- `qbft.requesttimeoutseconds: 4`: timeout khi consensus chậm.
- `blockchain.nodes.count: 4`: tạo dữ liệu cho 4 node.
- `alloc`: cấp sẵn balance cho tài khoản bootstrap.

Hiểu nhanh:

- Đây là "bản thiết kế chain" trước khi chạy.
- Script `scripts/generate-network.sh` sẽ dùng file này để sinh `nodes/networkFiles/genesis.json`.

## `.env`

Biến môi trường hiện tại:

```env
BESU_IMAGE=hyperledger/besu:latest
NETWORK_ID=1337
MIN_GAS_PRICE=0
```

Ý nghĩa:

- `BESU_IMAGE`: phiên bản image Besu dùng để chạy container.
- `NETWORK_ID`: network id ở lớp protocol/networking.
- `MIN_GAS_PRICE=0`: cho phép phí rất thấp khi dev local.

## `docker-compose.yml`

File này định nghĩa 4 service: `node-1` đến `node-4`.

Mỗi node gồm:

- `--data-path`: nơi lưu dữ liệu chain của node.
- `--genesis-file`: trỏ đến genesis đã generate.
- `--network-id`: khớp với `NETWORK_ID`.
- `--rpc-http-*`, `--rpc-ws-*`: bật/tắt RPC API.
- `--bootnodes`: danh sách điểm khởi đầu để node kết nối P2P.
- `--data-storage-format=BONSAI`: định dạng lưu state.

Khác biệt đáng chú ý:

- Node-1/2/3 mở API quản trị nhiều hơn.
- Node-4 giới hạn API, phù hợp làm RPC-facing node cho app ngoài.

## Khi nào cần sửa config?

- Đổi tốc độ block: chỉnh `qbft.blockperiodseconds`.
- Đổi chain dev: chỉnh `chainId` và `NETWORK_ID` đồng bộ.
- Hạn chế API: giảm `rpc-http-api` trên node public-facing.
- Đổi port xung đột: chỉnh mapping trong `docker-compose.yml`.
