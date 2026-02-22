# 05. Giải thích network của project

Nếu gặp thuật ngữ lạ, xem: `docs/01-jargon.md`.

## Kiến trúc mạng hiện tại

Mạng có 4 node Besu:

- `node-1`: validator + RPC (`8545`)
- `node-2`: validator + RPC (`8546`)
- `node-3`: validator + RPC (`8547`)
- `node-4`: RPC-facing (`8548`)

P2P ports:

- node-1: `30303`
- node-2: `30304`
- node-3: `30305`
- node-4: `30306`

## Vai trò từng lớp kết nối

- `P2P layer`: node nói chuyện với nhau để đồng bộ tx/block.
- `RPC layer`: app bên ngoài gọi API để đọc/ghi blockchain.

Vì vậy:

- App thường gọi RPC vào node-4.
- Node-4 phát tán transaction vào mạng qua P2P.

## Luồng transaction từ app đến block

1. Backend ký transaction.
2. Gửi transaction đến `http://localhost:8548`.
3. Node-4 nhận tx và broadcast cho các peer.
4. Validator set chạy QBFT để chọn/commit block.
5. Block đồng bộ sang toàn mạng.
6. Backend đọc receipt bằng `eth_getTransactionReceipt`.

## RPC node và validator có phải một không?

Không bắt buộc.

- `RPC node`: trọng tâm là phục vụ API cho app.
- `Validator`: trọng tâm là tham gia consensus.

Một node có thể vừa là RPC vừa là validator nếu cấu hình như vậy.

## Cách vận hành mạng nhanh

Windows menu:

```bat
start.bat
```

CLI:

```bash
bash scripts/generate-network.sh
docker compose up -d
bash scripts/network-status.sh
docker compose down
```

## Cách kiểm tra network đang khỏe

- Block number tăng đều theo thời gian.
- Peer count > 0, lý tưởng là các node thấy nhau đầy đủ.
- `network-status.sh` báo block production active.
