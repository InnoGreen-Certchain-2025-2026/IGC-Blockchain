# 02. Ethereum cơ bản cho project này

Nếu gặp thuật ngữ lạ, xem: `docs/01-jargon.md`.

## Ethereum là gì trong ngữ cảnh dự án?

Ethereum là nền tảng blockchain hỗ trợ smart contract chạy trên EVM.

Project này không chạy Ethereum public mainnet, mà chạy một mạng Ethereum-compatible private bằng Besu.

## 5 thành phần cốt lõi của Ethereum

- `Account`: tài khoản người dùng hoặc contract account.
- `Transaction`: yêu cầu thay đổi trạng thái chain.
- `Block`: tập transaction đã được xác nhận.
- `State`: trạng thái hiện tại (balance, nonce, storage).
- `EVM`: môi trường thực thi bytecode smart contract.

## EOA và Contract Account

- `EOA` (Externally Owned Account): tài khoản có private key, dùng để ký tx.
- `Contract Account`: tài khoản là smart contract, không có private key riêng.

Trong project, tài khoản deployer ký tx để deploy/call contract qua Hardhat.

## Đọc và ghi dữ liệu khác nhau thế nào?

- Đọc (`eth_call`): không tạo tx, không tốn gas on-chain, không sinh block mới.
- Ghi (`eth_sendRawTransaction`): tạo tx thật, đi qua consensus, có receipt, có phí gas.

## Chain ID và Network ID

- `chainId`: gắn trong chữ ký transaction để chống replay giữa chain khác nhau.
- `networkId`: ID ở mức networking/protocol handshake.

Trong dự án:

- `chainId = 1337`
- `NETWORK_ID = 1337`

## Gas là gì?

- `gas limit`: số đơn vị gas tối đa cho một transaction.
- `gas price`: giá mỗi đơn vị gas.
- `fee = gasUsed * gasPrice`.

Project đặt `MIN_GAS_PRICE=0` để tiện dev local.

## Event log dùng để làm gì?

Contract có thể `emit event` khi có hành động quan trọng (issue/revoke certificate...).

Backend thường nghe event để:

- Đồng bộ dữ liệu off-chain
- Audit hành động theo thời gian
- Trigger workflow nghiệp vụ
