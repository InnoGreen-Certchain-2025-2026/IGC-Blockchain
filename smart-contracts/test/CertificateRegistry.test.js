const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CertificateRegistry", function () {
  let certificateRegistry;
  let owner;
  let addr1;
  let addr2;

  const ISSUER_NAME = "Đại học Bách Khoa";

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const CertificateRegistry = await ethers.getContractFactory(
      "CertificateRegistry",
    );
    certificateRegistry = await CertificateRegistry.deploy(ISSUER_NAME);
    await certificateRegistry.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right admin", async function () {
      expect(await certificateRegistry.admin()).to.equal(owner.address);
    });

    it("Should set the right issuer name", async function () {
      expect(await certificateRegistry.issuerName()).to.equal(ISSUER_NAME);
    });

    it("Should start with zero certificates", async function () {
      expect(await certificateRegistry.totalCertificates()).to.equal(0);
    });
  });

  describe("Issue Certificate", function () {
    it("Should issue certificate successfully", async function () {
      const certId = "CERT-2024-001";
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));

      await expect(certificateRegistry.issueCertificate(certId, hash))
        .to.emit(certificateRegistry, "CertificateIssued")
        .withArgs(
          certId,
          hash,
          await ethers.provider.getBlock("latest").then((b) => b.timestamp + 1),
          owner.address,
        );

      expect(await certificateRegistry.totalCertificates()).to.equal(1);
    });

    it("Should fail if certificate already exists", async function () {
      const certId = "CERT-2024-001";
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));

      await certificateRegistry.issueCertificate(certId, hash);

      await expect(
        certificateRegistry.issueCertificate(certId, hash),
      ).to.be.revertedWith("Certificate already exists");
    });

    it("Should fail if not admin", async function () {
      const certId = "CERT-2024-001";
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));

      await expect(
        certificateRegistry.connect(addr1).issueCertificate(certId, hash),
      ).to.be.revertedWith("Only admin can perform this action");
    });
  });

  describe("Verify Certificate", function () {
    beforeEach(async function () {
      const certId = "CERT-2024-001";
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));
      await certificateRegistry.issueCertificate(certId, hash);
    });

    it("Should verify certificate by ID", async function () {
      const result = await certificateRegistry.verifyCertificate(
        "CERT-2024-001",
      );
      expect(result[0]).to.equal("CERT-2024-001");
      expect(result[3]).to.equal(true); // isValid
    });

    it("Should verify certificate by hash", async function () {
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));
      const result = await certificateRegistry.verifyCertificateByHash(hash);
      expect(result[0]).to.equal("CERT-2024-001");
      expect(result[3]).to.equal(true);
    });

    it("Should fail if certificate does not exist", async function () {
      await expect(
        certificateRegistry.verifyCertificate("CERT-9999"),
      ).to.be.revertedWith("Certificate does not exist");
    });
  });

  describe("Revoke Certificate", function () {
    beforeEach(async function () {
      const certId = "CERT-2024-001";
      const hash = ethers.keccak256(ethers.toUtf8Bytes("certificate data"));
      await certificateRegistry.issueCertificate(certId, hash);
    });

    it("Should revoke certificate", async function () {
      await expect(
        certificateRegistry.revokeCertificate("CERT-2024-001"),
      ).to.emit(certificateRegistry, "CertificateRevoked");

      expect(
        await certificateRegistry.isCertificateValid("CERT-2024-001"),
      ).to.equal(false);
    });

    it("Should fail if already revoked", async function () {
      await certificateRegistry.revokeCertificate("CERT-2024-001");

      await expect(
        certificateRegistry.revokeCertificate("CERT-2024-001"),
      ).to.be.revertedWith("Certificate already revoked");
    });
  });
});
