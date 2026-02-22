# 02. Cài đặt môi trường

## Cần cài những gì?

- Docker Desktop
- Git Bash hoặc WSL
- Node.js LTS + npm

## Kiểm tra nhanh

Chạy các lệnh sau:

```bash
docker --version
docker compose version
bash --version
node --version
npm --version
```

Nếu lệnh nào báo không tìm thấy, cần cài thêm công cụ tương ứng.

## Cấu hình môi trường dự án

File `.env` ở root hiện có:

```env
BESU_IMAGE=hyperledger/besu:latest
NETWORK_ID=1337
MIN_GAS_PRICE=0
```

Bạn có thể giữ nguyên để chạy local.
