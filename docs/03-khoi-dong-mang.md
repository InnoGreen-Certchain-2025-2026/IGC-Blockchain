# 03. Khởi động mạng blockchain

## Cách nhanh nhất (Windows)

Chạy:

```bat
start.bat
```

Menu có các chức năng:

- `1`: Reset network (xóa data cũ + sinh lại mạng)
- `2`: Start nodes
- `3`: Stop nodes
- `4`: Network status

## Cách chạy bằng lệnh

Sinh cấu hình mạng:

```bash
bash scripts/generate-network.sh
```

Khởi động node:

```bash
docker compose up -d
```

Kiểm tra trạng thái:

```bash
bash scripts/network-status.sh
```

Dừng mạng:

```bash
docker compose down
```

## Endpoint để gọi RPC

- `http://localhost:8545` (Node 1)
- `http://localhost:8546` (Node 2)
- `http://localhost:8547` (Node 3)
- `http://localhost:8548` (Node 4)
