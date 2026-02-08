// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title CertificateRegistry
 * @dev Smart Contract lưu trữ hash chứng chỉ trên blockchain
 * @notice Chỉ lưu: mã chứng chỉ, hash, đơn vị cấp, thời gian
 * Thông tin chi tiết lưu trong PostgreSQL off-chain
 */
contract CertificateRegistry {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    address public admin;
    string public issuerName;  // Tên trường/đơn vị cấp
    uint256 public totalCertificates;
    
    // ============================================
    // DATA STRUCTURES
    // ============================================
    
    /**
     * @dev Cấu trúc chứng chỉ tối giản
     */
    struct Certificate {
        string certificateId;      // Mã chứng chỉ (VD: "CERT-2024-001")
        bytes32 documentHash;      // SHA-256 hash của toàn bộ thông tin chứng chỉ
        uint256 issueTimestamp;    // Thời gian cấp (Unix timestamp)
        bool isValid;              // Trạng thái hiệu lực
        bool exists;               // Kiểm tra tồn tại
    }
    
    // ============================================
    // STORAGE
    // ============================================
    
    // Mapping: certificateId => Certificate
    mapping(string => Certificate) private certificates;
    
    // Mapping: hash => certificateId (để verify bằng hash)
    mapping(bytes32 => string) private hashToCertId;
    
    // Danh sách tất cả certificateId
    string[] private allCertificateIds;
    
    // ============================================
    // EVENTS
    // ============================================
    
    event CertificateIssued(
        string indexed certificateId,
        bytes32 indexed documentHash,
        uint256 issueTimestamp,
        address issuedBy
    );
    
    event CertificateRevoked(
        string indexed certificateId,
        uint256 revokeTimestamp,
        address revokedBy
    );
    
    event IssuerNameUpdated(
        string oldName,
        string newName,
        uint256 timestamp
    );
    
    // ============================================
    // MODIFIERS
    // ============================================
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier certificateExists(string memory _certId) {
        require(certificates[_certId].exists, "Certificate does not exist");
        _;
    }
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    
    constructor(string memory _issuerName) {
        require(bytes(_issuerName).length > 0, "Issuer name cannot be empty");
        
        admin = msg.sender;
        issuerName = _issuerName;
        totalCertificates = 0;
    }
    
    // ============================================
    // MAIN FUNCTIONS
    // ============================================
    
    /**
     * @dev Cấp chứng chỉ mới
     * @param _certificateId Mã chứng chỉ duy nhất
     * @param _documentHash Hash SHA-256 của toàn bộ thông tin chứng chỉ
     * @return success Trả về true nếu thành công
     */
    function issueCertificate(
        string memory _certificateId,
        bytes32 _documentHash
    ) public onlyAdmin returns (bool success) {
        require(bytes(_certificateId).length > 0, "Certificate ID cannot be empty");
        require(_documentHash != bytes32(0), "Document hash cannot be empty");
        require(!certificates[_certificateId].exists, "Certificate already exists");
        require(bytes(hashToCertId[_documentHash]).length == 0, "Hash already exists");
        
        // Tạo certificate mới
        certificates[_certificateId] = Certificate({
            certificateId: _certificateId,
            documentHash: _documentHash,
            issueTimestamp: block.timestamp,
            isValid: true,
            exists: true
        });
        
        // Lưu mapping hash => certId
        hashToCertId[_documentHash] = _certificateId;
        
        // Thêm vào danh sách
        allCertificateIds.push(_certificateId);
        
        // Tăng counter
        totalCertificates++;
        
        // Emit event
        emit CertificateIssued(
            _certificateId,
            _documentHash,
            block.timestamp,
            msg.sender
        );
        
        return true;
    }
    
    /**
     * @dev Xác thực chứng chỉ bằng mã chứng chỉ
     * @param _certificateId Mã chứng chỉ
     * @return certId Mã chứng chỉ
     * @return docHash Hash của chứng chỉ
     * @return issueTime Thời gian cấp
     * @return valid Trạng thái hiệu lực
     */
    function verifyCertificate(string memory _certificateId)
        public
        view
        certificateExists(_certificateId)
        returns (
            string memory certId,
            bytes32 docHash,
            uint256 issueTime,
            bool valid
        )
    {
        Certificate memory cert = certificates[_certificateId];
        return (
            cert.certificateId,
            cert.documentHash,
            cert.issueTimestamp,
            cert.isValid
        );
    }
    
    /**
     * @dev Xác thực chứng chỉ bằng hash
     * @param _documentHash Hash của chứng chỉ
     * @return certId Mã chứng chỉ
     * @return docHash Hash của chứng chỉ
     * @return issueTime Thời gian cấp
     * @return valid Trạng thái hiệu lực
     */
    function verifyCertificateByHash(bytes32 _documentHash)
        public
        view
        returns (
            string memory certId,
            bytes32 docHash,
            uint256 issueTime,
            bool valid
        )
    {
        string memory certIdFound = hashToCertId[_documentHash];
        require(bytes(certIdFound).length > 0, "Certificate not found for this hash");
        
        Certificate memory cert = certificates[certIdFound];
        return (
            cert.certificateId,
            cert.documentHash,
            cert.issueTimestamp,
            cert.isValid
        );
    }
    
    /**
     * @dev Kiểm tra chứng chỉ có hợp lệ không
     * @param _certificateId Mã chứng chỉ
     * @return Trạng thái hợp lệ
     */
    function isCertificateValid(string memory _certificateId)
        public
        view
        certificateExists(_certificateId)
        returns (bool)
    {
        return certificates[_certificateId].isValid;
    }
    
    /**
     * @dev Thu hồi chứng chỉ
     * @param _certificateId Mã chứng chỉ
     * @return success Trả về true nếu thành công
     */
    function revokeCertificate(string memory _certificateId)
        public
        onlyAdmin
        certificateExists(_certificateId)
        returns (bool success)
    {
        require(certificates[_certificateId].isValid, "Certificate already revoked");
        
        certificates[_certificateId].isValid = false;
        
        emit CertificateRevoked(
            _certificateId,
            block.timestamp,
            msg.sender
        );
        
        return true;
    }
    
    /**
     * @dev Kích hoạt lại chứng chỉ đã thu hồi
     * @param _certificateId Mã chứng chỉ
     * @return success Trả về true nếu thành công
     */
    function reactivateCertificate(string memory _certificateId)
        public
        onlyAdmin
        certificateExists(_certificateId)
        returns (bool success)
    {
        require(!certificates[_certificateId].isValid, "Certificate is already valid");
        
        certificates[_certificateId].isValid = true;
        
        return true;
    }
    
    /**
     * @dev Lấy hash của chứng chỉ
     * @param _certificateId Mã chứng chỉ
     * @return Hash của chứng chỉ
     */
    function getCertificateHash(string memory _certificateId)
        public
        view
        certificateExists(_certificateId)
        returns (bytes32)
    {
        return certificates[_certificateId].documentHash;
    }
    
    /**
     * @dev Kiểm tra chứng chỉ có tồn tại không
     * @param _certificateId Mã chứng chỉ
     * @return Có tồn tại hay không
     */
    function certificateExistsCheck(string memory _certificateId)
        public
        view
        returns (bool)
    {
        return certificates[_certificateId].exists;
    }
    
    /**
     * @dev Lấy tổng số chứng chỉ đã cấp
     * @return Tổng số chứng chỉ
     */
    function getTotalCertificates() public view returns (uint256) {
        return totalCertificates;
    }
    
    /**
     * @dev Lấy danh sách mã chứng chỉ (phân trang)
     * @param _offset Vị trí bắt đầu
     * @param _limit Số lượng tối đa
     * @return Danh sách mã chứng chỉ
     */
    function getCertificateIds(uint256 _offset, uint256 _limit)
        public
        view
        returns (string[] memory)
    {
        require(_offset < allCertificateIds.length, "Offset out of bounds");
        
        uint256 end = _offset + _limit;
        if (end > allCertificateIds.length) {
            end = allCertificateIds.length;
        }
        
        uint256 size = end - _offset;
        string[] memory result = new string[](size);
        
        for (uint256 i = 0; i < size; i++) {
            result[i] = allCertificateIds[_offset + i];
        }
        
        return result;
    }
    
    // ============================================
    // ADMIN FUNCTIONS
    // ============================================
    
    /**
     * @dev Cập nhật tên đơn vị cấp
     * @param _newIssuerName Tên mới
     */
    function updateIssuerName(string memory _newIssuerName)
        public
        onlyAdmin
    {
        require(bytes(_newIssuerName).length > 0, "Issuer name cannot be empty");
        
        string memory oldName = issuerName;
        issuerName = _newIssuerName;
        
        emit IssuerNameUpdated(oldName, _newIssuerName, block.timestamp);
    }
    
    /**
     * @dev Chuyển quyền admin
     * @param _newAdmin Địa chỉ admin mới
     */
    function transferAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        require(_newAdmin != admin, "New admin is the same as current admin");
        
        admin = _newAdmin;
    }
}