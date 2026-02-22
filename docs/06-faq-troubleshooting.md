# 06. FAQ và Troubleshooting

## 1) Bấm reset/status trong `start.bat` nhưng không chạy

Nguyên nhân thường do thiếu `bash`.

Giải pháp:

- Cài Git Bash hoặc WSL
- Mở terminal mới và chạy lại

## 2) Docker báo lỗi kết nối hoặc không start container

Giải pháp:

- Mở Docker Desktop
- Chờ Docker chạy ổn định rồi thử lại
- Kiểm tra bằng `docker ps`

## 3) Báo port đã được sử dụng

Các port dùng mặc định:

- RPC: `8545-8548`
- P2P: `30303-30306`

Giải pháp:

- Tắt service đang chiếm port
- Hoặc đổi mapping trong `docker-compose.yml`

## 4) Không thấy thư mục `nodes/`

`nodes/` chỉ xuất hiện sau khi chạy:

```bash
bash scripts/generate-network.sh
```

## 5) Test smart contract fail

Giải pháp:

- Vào đúng thư mục: `smart-contracts/`
- Chạy lại `npm install`
- Chạy `npx hardhat compile` trước rồi `npx hardhat test`
