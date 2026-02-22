# 06. Giải thích smart contract của project

Nếu gặp thuật ngữ lạ, xem: `docs/01-jargon.md`.

Thư mục làm việc: `smart-contracts/`.

## Mục tiêu smart contract trong dự án

Project có 2 contract chính:

- `SimpleStorage.sol`: contract demo để test luồng deploy/call.
- `CertificateRegistry.sol`: contract nghiệp vụ chứng chỉ.

## `SimpleStorage.sol` làm gì?

Chức năng:

- Lưu một số nguyên `storedData`
- Có hàm `set`, `get`, `increment`, `decrement`
- Có `owner` và `transferOwnership`
- Emit event `DataStored` khi dữ liệu đổi

Mục đích:

- Dùng để kiểm tra nhanh mạng có ghi/đọc được không.
- Dùng script `interact.js` để demo call transaction.

## `CertificateRegistry.sol` làm gì?

Đây là contract nghiệp vụ chính:

- Admin cấp chứng chỉ bằng `certificateId + documentHash`
- Xác thực chứng chỉ theo ID hoặc hash
- Thu hồi và kích hoạt lại chứng chỉ
- Quản lý `issuerName`, chuyển quyền admin

Dữ liệu on-chain được tối giản:

- Mã chứng chỉ
- Hash tài liệu
- Thời điểm cấp
- Trạng thái hiệu lực

Ý tưởng kiến trúc:

- On-chain lưu bằng chứng và trạng thái xác thực.
- Dữ liệu chi tiết hồ sơ lưu ở hệ thống off-chain (DB/backend).

## Test và deploy trong project

### Test

- File test: `smart-contracts/test/CertificateRegistry.test.js`
- Kiểm tra các case chính: deploy, issue, verify, revoke, phân quyền admin.

### Deploy

- Script deploy: `smart-contracts/scripts/deploy.js`
- Output metadata:
- `smart-contracts/certificate-deployments.json`
- `smart-contracts/certificate-contract.json` (địa chỉ + ABI)

### Interact

- Script demo call: `smart-contracts/scripts/interact.js`
- Dùng để gửi tx đọc/ghi với `SimpleStorage`.

## Lệnh cơ bản

```bash
cd smart-contracts
npm install
npx hardhat compile
npx hardhat test
```

Deploy lên Besu network (đã cấu hình trong Hardhat):

```bash
npx hardhat run scripts/deploy.js --network besu
```
