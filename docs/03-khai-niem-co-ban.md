# 05. Khái niệm cơ bản

## Blockchain private là gì?

Là mạng blockchain chỉ cho phép các node được cấp quyền tham gia.

## Node là gì?

Node là một máy/chương trình tham gia mạng blockchain:

- Lưu dữ liệu blockchain
- Giao tiếp với node khác
- Xác thực và tạo block (nếu là validator)

## Validator là gì?

Validator là node có quyền tham gia đồng thuận để tạo block mới.

## RPC là gì?

RPC là API để ứng dụng bên ngoài gọi vào blockchain (đọc dữ liệu, gửi giao dịch).

## Genesis file là gì?

`genesis.json` là cấu hình khởi tạo chain:

- Chain ID / network ID
- Cơ chế đồng thuận
- Tài khoản cấp sẵn (nếu có)

## QBFT là gì?

QBFT là cơ chế đồng thuận theo mô hình Byzantine Fault Tolerance, phù hợp mạng private.
