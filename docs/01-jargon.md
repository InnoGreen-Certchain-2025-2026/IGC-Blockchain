# 00. Từ điển thuật ngữ (Jargon)

## Thuật ngữ cốt lõi

- `Node`: một instance chương trình blockchain tham gia mạng.
- `Besu`: Ethereum client dùng để chạy node (thực thi EVM, lưu state, giao tiếp P2P, mở RPC).
- `Private chain`: blockchain nội bộ, không mở công khai như Ethereum mainnet.
- `Permissioned`: chỉ node/tài khoản được cấp quyền mới được tham gia thao tác nhất định.
- `Ledger`: sổ cái dữ liệu giao dịch và trạng thái.
- `State`: trạng thái hiện tại của chain (balance, nonce, storage contract).
- `Block`: gói dữ liệu chứa danh sách transaction đã được xác nhận.
- `Transaction (tx)`: yêu cầu thay đổi state, ví dụ gọi hàm ghi của smart contract.
- `Finality`: tính "chốt" của block, sau khi finalized thì khó/không bị đảo ngược.

## Mạng và đồng thuận

- `P2P`: cơ chế node giao tiếp trực tiếp với nhau để đồng bộ tx/block.
- `Peer`: node hàng xóm mà node hiện tại đang kết nối.
- `Consensus`: cơ chế để nhiều node thống nhất block hợp lệ.
- `QBFT`: thuật toán đồng thuận BFT cho mạng permissioned của Besu.
- `Validator`: node có quyền tham gia biểu quyết/tạo block trong consensus.
- `Proposer`: validator đang tới lượt đề xuất block.
- `Quorum`: số lượng phiếu tối thiểu để chấp nhận block.

## API và tích hợp ứng dụng

- `RPC`: giao diện để app ngoài gọi node blockchain.
- `JSON-RPC`: format request/response chuẩn dạng JSON qua HTTP/WS.
- `RPC node`: node ưu tiên phục vụ API cho ứng dụng.
- `eth_sendRawTransaction`: API gửi transaction đã ký.
- `eth_call`: API đọc dữ liệu contract không tạo transaction.
- `eth_getTransactionReceipt`: API kiểm tra kết quả transaction.
- `ABI`: mô tả hàm/sự kiện của contract để app gọi đúng format.

## Smart contract và công cụ

- `Smart contract`: chương trình chạy trên EVM.
- `EVM`: máy ảo thực thi bytecode contract Ethereum.
- `Solidity`: ngôn ngữ viết smart contract.
- `Hardhat`: bộ công cụ dev smart contract (compile/test/deploy).
- `Artifact`: output compile chứa ABI + bytecode.

## Vận hành

- `Genesis`: file khởi tạo chain từ block đầu tiên.
- `Chain ID`: ID chain để tránh replay transaction giữa mạng khác nhau.
- `Network ID`: ID mạng cho lớp kết nối peer/client.
- `Gas`: đơn vị đo chi phí tính toán EVM.
- `Gas price`: giá trả cho mỗi đơn vị gas.
- `Mempool`: hàng đợi transaction hợp lệ đang chờ vào block.
- `Bonsai`: kiểu lưu trữ state trong Besu, tối ưu dung lượng/hiệu năng theo ngữ cảnh.
