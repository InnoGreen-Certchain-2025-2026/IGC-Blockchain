# 03. Hyperledger Besu chi tiết (dành cho người mới)

Nếu gặp thuật ngữ lạ, xem nhanh: `docs/01-jargon.md`.

## Besu là gì?

Hyperledger Besu là Ethereum client mã nguồn mở, hỗ trợ cả mạng public và private.  
Trong dự án này, Besu được dùng để chạy mạng private theo đồng thuận QBFT.

Bạn có thể hiểu đơn giản:

- Besu = ứng dụng node blockchain
- Mỗi container Besu = một node trong mạng
- Nhiệm vụ node: nhận giao dịch, xác thực, lưu block/state, đồng bộ với node khác

## Besu trong mô hình Ethereum

Besu thực hiện đồng thời nhiều vai trò kỹ thuật:

- `Execution client`: tiến trình thực thi EVM (máy ảo chạy smart contract)
- `P2P node`: kết nối peer (node hàng xóm), gossip (phát tán) transaction/block
- `State manager`: duy trì state (trạng thái hiện tại của chain)
- `RPC server`: cung cấp API cho ứng dụng bên ngoài

Với private chain, Besu còn đóng vai trò "hạ tầng doanh nghiệp":

- Cấu hình permissioned network
- Kiểm soát API/phạm vi truy cập
- Tối ưu hiệu năng và quan sát mạng nội bộ

## Thành phần Besu trong project này

Mạng hiện có 4 node trong `docker-compose.yml`:

- `node-1`: Validator + RPC
- `node-2`: Validator + RPC
- `node-3`: Validator + RPC
- `node-4`: RPC-facing node (cho app ngoài gọi vào), có API hẹp hơn

Lưu ý quan trọng:

- "Node RPC" không tự động nghĩa là "không validator".
- Node có validator hay không do dữ liệu genesis/validator set quyết định.
- API bật/tắt trong `docker-compose.yml` chỉ quyết định node đó cho phép gọi method nào.

## Besu lưu gì?

Besu không chỉ lưu "danh sách block". Nó lưu:

- Block headers và block bodies
- Trạng thái tài khoản (state trie): balance, nonce, contract storage
- Receipt (kết quả thực thi tx) và event logs
- Mempool (hàng đợi transaction đang chờ vào block)
- Dữ liệu peer/network

Trong compose của bạn đang dùng:

- `--data-storage-format=BONSAI` (tối ưu lưu state)

## Besu tạo block thế nào trong QBFT?

Trong mạng QBFT:

- Validator thay phiên nhau làm proposer
- Proposer đề xuất block từ tx trong mempool
- Các validator bỏ phiếu/commit theo QBFT
- Khi đủ quorum (đủ phiếu tối thiểu), block được finalized (chốt)

Diễn giải dễ hiểu:

1. Node nhận transaction hợp lệ và giữ trong mempool.
2. Đến lượt proposer, validator đó gom transaction tạo block proposal.
3. Các validator còn lại kiểm tra proposal và bỏ phiếu.
4. Khi đủ chữ ký/phiếu theo quy tắc QBFT, block được commit.
5. Block đã commit mang tính finality (không cần chờ nhiều confirm như PoW).

Điểm cốt lõi:

- Ứng dụng bên ngoài không gọi "create block".
- Ứng dụng chỉ gửi transaction (JSON-RPC).
- Consensus engine QBFT quyết định khi nào block được tạo.

## Vòng đời một transaction trong hệ của bạn

1. Backend ký transaction bằng private key của tài khoản gửi.
2. Backend gọi `eth_sendRawTransaction` vào `http://localhost:8548`.
3. Node-4 kiểm tra format/signature rồi phát tán tx qua mạng P2P.
4. Validator nhận tx, đưa vào mempool cục bộ.
5. Proposer chọn tx, đưa vào block và phát proposal.
6. QBFT finalize block.
7. Tất cả node cập nhật state giống nhau.
8. Backend theo dõi `txHash` bằng `eth_getTransactionReceipt`.

## App ngoài gọi Besu như thế nào?

App ngoài (backend/mobile/web) sẽ gọi JSON-RPC:

- Gửi tx: `eth_sendRawTransaction`
- Đọc block: `eth_blockNumber`, `eth_getBlockByNumber`
- Đọc state: `eth_call`, `eth_getBalance`
- Log/events: `eth_getLogs`

Trong project này, Hardhat đang trỏ vào:

- `http://localhost:8548` (node-4)

Đây là một lựa chọn kiến trúc phổ biến:

- App chỉ đi qua một node RPC-facing
- Validator tách biệt để giảm rủi ro vận hành

## Vai trò của node-4 trong dự án hiện tại

Node-4 đang được cấu hình API giới hạn hơn các validator:

- Có: `ETH, NET, WEB3, DEBUG, TRACE, TXPOOL`
- Không mở: `QBFT`, `ADMIN`

Ý nghĩa:

- Node-4 thiên về phục vụ truy cập ứng dụng
- Tránh lộ bớt API quản trị/đồng thuận ra ngoài

Kết luận thực dụng:

- App ngoài nên ưu tiên gọi node-4.
- Validator nên hạn chế mở API quản trị ra ngoài.
- Muốn chắc node-4 không validate thì cần xác nhận validator set trong genesis.

## Vì sao vẫn cần nhiều node nếu app chỉ gọi một RPC?

Vì blockchain là hệ phân tán:

- Nhiều node giúp tăng độ sẵn sàng
- Validator phân tán giúp chống single point of failure
- Khi một node lỗi, các node khác vẫn duy trì chain

## Các cổng bạn đang dùng

RPC HTTP:

- `8545` -> node-1
- `8546` -> node-2
- `8547` -> node-3
- `8548` -> node-4

P2P:

- `30303` -> node-1
- `30304` -> node-2
- `30305` -> node-3
- `30306` -> node-4

## Ý nghĩa các thông số quan trọng trong project

- `NETWORK_ID=1337`: định danh mạng để client không gửi nhầm chain.
- `MIN_GAS_PRICE=0`: cho phép tx gas price rất thấp khi chạy local.
- `blockperiodseconds=2` trong QBFT config: mục tiêu mỗi ~2 giây có block mới.
- `requesttimeoutseconds=4`: timeout trong tiến trình đồng thuận QBFT.
- `chainId=1337`: chống replay tx giữa các chain khác nhau.

## Dữ liệu node nằm ở đâu?

Sau khi generate mạng:

- `nodes/networkFiles/genesis.json`: genesis thực tế dùng để chạy node
- `nodes/node-1/data` ... `nodes/node-4/data`: key và data từng node

Thực tế vận hành:

- Mỗi node có data riêng
- Mất data node có thể đồng bộ lại từ peer (tùy trạng thái mạng)
- Mất đồng loạt data tất cả node thì chain local coi như reset

## API groups thường gặp trong compose của bạn

- `ETH`: nhóm API Ethereum cơ bản
- `NET`: thông tin network
- `WEB3`: utility API
- `QBFT`: quản trị/thông tin đồng thuận QBFT
- `ADMIN`: peer/admin operation
- `DEBUG`, `TRACE`, `TXPOOL`: debug, trace execution, xem mempool

Khuyến nghị:

- Chỉ bật API cần thiết
- Không public các API admin nếu không có reverse proxy/bảo vệ mạng nội bộ

## Những hiểu nhầm phổ biến

- "Gọi RPC là tạo block": sai, RPC chỉ gửi tx hoặc đọc chain.
- "Node RPC thì không lưu chain": sai, node RPC vẫn đồng bộ và lưu dữ liệu.
- "Chỉ cần 1 validator là đủ": sai với BFT production, cần nhiều validator để chịu lỗi.
- "Besu chỉ là DB": sai, Besu là execution + consensus + network node.

## Tóm tắt đúng bản chất

- Besu là node blockchain app, không phải "database app" thuần.
- Node nhận transaction, gossip qua mạng, consensus tạo block, rồi đồng bộ.
- Node-4 là cổng RPC tiện cho app ngoài; app ngoài gửi transaction, không trực tiếp tạo block.
- Việc tạo block thuộc về validator + QBFT, không phải do client quyết định trực tiếp.
