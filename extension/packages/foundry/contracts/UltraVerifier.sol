// Verification Key Hash: fde33953950dca32ad952830f28e91583f35e5fce8edc8d4abb1e285ab853428
// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec
pragma solidity >=0.8.4;

import "./BaseUltraVerifier.sol";

library UltraVerificationKey {
  function verificationKeyHash() internal pure returns (bytes32) {
    return 0xfde33953950dca32ad952830f28e91583f35e5fce8edc8d4abb1e285ab853428;
  }

  function loadVerificationKey(
    uint256 _vk,
    uint256 _omegaInverseLoc
  ) internal pure {
    assembly {
      mstore(
        add(_vk, 0x00),
        0x0000000000000000000000000000000000000000000000000000000000040000
      ) // vk.circuit_size
      mstore(
        add(_vk, 0x20),
        0x0000000000000000000000000000000000000000000000000000000000000021
      ) // vk.num_inputs
      mstore(
        add(_vk, 0x40),
        0x19ddbcaf3a8d46c15c0176fbb5b95e4dc57088ff13f4d1bd84c6bfa57dcdc0e0
      ) // vk.work_root
      mstore(
        add(_vk, 0x60),
        0x30644259cd94e7dd5045d7a27013b7fcd21c9e3b7fa75222e7bda49b729b0401
      ) // vk.domain_inverse
      mstore(
        add(_vk, 0x80),
        0x14e5ccbe941cdedca7ff8258063639bcd5ce96bb9ba07f0f214bdf93b5c1903f
      ) // vk.Q1.x
      mstore(
        add(_vk, 0xa0),
        0x0ceac4286b1649c98ae9a7979bee54f1b3778d972e552a4fe509c04aee443385
      ) // vk.Q1.y
      mstore(
        add(_vk, 0xc0),
        0x0d51b6ae47bf0ec018b7c864e9182f230dcb6d2e394c4d87001901516788ada8
      ) // vk.Q2.x
      mstore(
        add(_vk, 0xe0),
        0x0c38f1521f3e6aae395e4010a7290dab3e5d952348fa03b6ba909b4e328e607f
      ) // vk.Q2.y
      mstore(
        add(_vk, 0x100),
        0x068e70dbd50eb247b3c79fb0a28a1408df224d78e6553d2e6ecbeceaacb14900
      ) // vk.Q3.x
      mstore(
        add(_vk, 0x120),
        0x0420bba2616efff7b9e46bc600b69515b18358bb42b9d7c0bd6afa933c2bd5ef
      ) // vk.Q3.y
      mstore(
        add(_vk, 0x140),
        0x146627e4bae49e7f3e6195238788066789faf48a061c035183c7d273c1968e6e
      ) // vk.Q4.x
      mstore(
        add(_vk, 0x160),
        0x200ba5acfbfc185cf24a63c9b41789af72206e1282e12155c748f9a75922723e
      ) // vk.Q4.y
      mstore(
        add(_vk, 0x180),
        0x2f3b9a3242c5bfb7aeb4e869e652c1ccaa1d40c7e6749cc4c079c21e0cc8cefb
      ) // vk.Q_M.x
      mstore(
        add(_vk, 0x1a0),
        0x009f331beef72c0bf4be75c16dc3828c13041e42b90dba5134adf9debac9c4b9
      ) // vk.Q_M.y
      mstore(
        add(_vk, 0x1c0),
        0x0f7ed2bc6cab74fbe44d1ea29dda8c7a2fe1e9b2650382f95cf8612f2a148ef8
      ) // vk.Q_C.x
      mstore(
        add(_vk, 0x1e0),
        0x135df336a98032409791f8a878e226528207a95d3ada91622082b1def1bec049
      ) // vk.Q_C.y
      mstore(
        add(_vk, 0x200),
        0x0fd0a17896fc11626168145a4b1360ae3d38f4a6e805f14e78da1e254b19b96e
      ) // vk.Q_ARITHMETIC.x
      mstore(
        add(_vk, 0x220),
        0x24e64dc44e59730fd2bab37ddf238ad93a5a90f490ddd0677db3ec54a2759d40
      ) // vk.Q_ARITHMETIC.y
      mstore(
        add(_vk, 0x240),
        0x2e0b0b0f9ba160aa27ce82f287b6796375da2ddbccc8f9e0be26d815a843ab4b
      ) // vk.QSORT.x
      mstore(
        add(_vk, 0x260),
        0x16ce887369406858dd90191d37653f0c025ac62757743d120710f447335c8f36
      ) // vk.QSORT.y
      mstore(
        add(_vk, 0x280),
        0x06629c46818b7f2b153efcf04623ec8cbd974275a3d4f3e951d7295b9c462f47
      ) // vk.Q_ELLIPTIC.x
      mstore(
        add(_vk, 0x2a0),
        0x00b4f0754488d4420ea7aa45808a9f0e9a732eb89aa92a860e102788392972fc
      ) // vk.Q_ELLIPTIC.y
      mstore(
        add(_vk, 0x2c0),
        0x164b15902231ec46a7df29295561607bc49c00ce59e6ce5d3e80f94dce193568
      ) // vk.Q_AUX.x
      mstore(
        add(_vk, 0x2e0),
        0x0fd0218515c616b12c79a6387bc3f162f2580dc1b9841deeeb739e64d316551e
      ) // vk.Q_AUX.y
      mstore(
        add(_vk, 0x300),
        0x2cb2fdfaaec695a2c48b6a87dba53ba75261bcf85fae8da169ae75ded8d53d48
      ) // vk.SIGMA1.x
      mstore(
        add(_vk, 0x320),
        0x220554ee2de8941fadf2cecb9dff49225eb784d0f31889496d09c4a4e275cef2
      ) // vk.SIGMA1.y
      mstore(
        add(_vk, 0x340),
        0x02a47c6dcf9afc9540d865b8a4b730430684bb8ba45021de498119be3ee28a61
      ) // vk.SIGMA2.x
      mstore(
        add(_vk, 0x360),
        0x04e3971354edeb1daf5fc6784473f66c61b87b64c920a9203d9ea51ad728bb49
      ) // vk.SIGMA2.y
      mstore(
        add(_vk, 0x380),
        0x1fc9df1562e5f42ddc9ab0107abe4ef860c66a84e573d2cf5695f6e46b38d6ed
      ) // vk.SIGMA3.x
      mstore(
        add(_vk, 0x3a0),
        0x2421aa899352d48db33c2be3b21c416d19b39a3e812db8fd9b48265f05b65fcf
      ) // vk.SIGMA3.y
      mstore(
        add(_vk, 0x3c0),
        0x17a12a757c012894d8065f033462fab3080c75b25a12d87844a4416fd8d47148
      ) // vk.SIGMA4.x
      mstore(
        add(_vk, 0x3e0),
        0x1a388ac2c162e73861c309aa55a343372b95c2e1b0093149baa3f9c84a55b4d1
      ) // vk.SIGMA4.y
      mstore(
        add(_vk, 0x400),
        0x24ec4e91a34243b3f0a0cad6b3e3e197e896fff5bd1184e6f356ab0d2b9e8f18
      ) // vk.TABLE1.x
      mstore(
        add(_vk, 0x420),
        0x295b8cfdda100a52cfff8890498f4245cdf3acfe71d98db3b338453988f6df78
      ) // vk.TABLE1.y
      mstore(
        add(_vk, 0x440),
        0x0474f7749df187ab47e1590590cddcfe2fda25c6ff4dfd26e7211f9730e4911f
      ) // vk.TABLE2.x
      mstore(
        add(_vk, 0x460),
        0x02d65a3f02db65058472601e184b9e0bc6619f0fec863b1e456bbe1cf238d060
      ) // vk.TABLE2.y
      mstore(
        add(_vk, 0x480),
        0x2d8baf693bf660e8fbc9ee8459ab99471e2e0010a1e7c7c0cedd07607d60711e
      ) // vk.TABLE3.x
      mstore(
        add(_vk, 0x4a0),
        0x215a1bb26337a4aaddc0d70a0ca1425448e582bbb026b47253328fe414fd9a6e
      ) // vk.TABLE3.y
      mstore(
        add(_vk, 0x4c0),
        0x225f3fbd31be1a72d035dd26b793c425832c21fd171a6490cd11a3ee9acd3da7
      ) // vk.TABLE4.x
      mstore(
        add(_vk, 0x4e0),
        0x0bfaa201bc5fdaceceab080752d855737b65c6cae330c210f6e11eeec0f55d41
      ) // vk.TABLE4.y
      mstore(
        add(_vk, 0x500),
        0x21484e12132de4ef032d93a009597bb204c7cd4e82db03f288a293b48adccba9
      ) // vk.TABLE_TYPE.x
      mstore(
        add(_vk, 0x520),
        0x22f42945b0c0b1e7c6420875c83c7749fc90a72e5dc3a347e5e6ce7efe23ceca
      ) // vk.TABLE_TYPE.y
      mstore(
        add(_vk, 0x540),
        0x2c003e09be7ccd16c25fe50f26836ec402e6a0d5fc855a51a8f2b2ff65485d03
      ) // vk.ID1.x
      mstore(
        add(_vk, 0x560),
        0x167af516636a884960ab7fd31b0be2c810a2f7b669e557966d7f04f02c1a1316
      ) // vk.ID1.y
      mstore(
        add(_vk, 0x580),
        0x1dfbf58c1c337b6256a21b7289c7f7dc5b081983f764ad506af79abb643cb329
      ) // vk.ID2.x
      mstore(
        add(_vk, 0x5a0),
        0x0c04c375e2f2cded451dd092ceda9ee6cf4c56d8d8ac419e3d325e5d8f7cd548
      ) // vk.ID2.y
      mstore(
        add(_vk, 0x5c0),
        0x1e460d8a70270ad01cb74518cb989e4fbe4e55d8cf6a6261064aa4862ded16d7
      ) // vk.ID3.x
      mstore(
        add(_vk, 0x5e0),
        0x0e744ffc9d2f41a9a48c3eb287fc5b650f6447e37f307038bd76438797d11756
      ) // vk.ID3.y
      mstore(
        add(_vk, 0x600),
        0x1fa018272cf7e6bf69ae3c4eba619f91fe6351623d7340bf765c243f0ab88153
      ) // vk.ID4.x
      mstore(
        add(_vk, 0x620),
        0x1eec6c52c43b63e177086d2044b5f3f3ee9e7245ce25bb5eebd2495fc16864a2
      ) // vk.ID4.y
      mstore(add(_vk, 0x640), 0x00) // vk.contains_recursive_proof
      mstore(add(_vk, 0x660), 0) // vk.recursive_proof_public_input_indices
      mstore(
        add(_vk, 0x680),
        0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1
      ) // vk.g2_x.X.c1
      mstore(
        add(_vk, 0x6a0),
        0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0
      ) // vk.g2_x.X.c0
      mstore(
        add(_vk, 0x6c0),
        0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4
      ) // vk.g2_x.Y.c1
      mstore(
        add(_vk, 0x6e0),
        0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55
      ) // vk.g2_x.Y.c0
      mstore(
        _omegaInverseLoc,
        0x036853f083780e87f8d7c71d111119c57dbe118c22d5ad707a82317466c5174c
      ) // vk.work_root_inverse
    }
  }
}

contract UltraVerifier is BaseUltraVerifier {
  function getVerificationKeyHash()
    public
    pure
    override(BaseUltraVerifier)
    returns (bytes32)
  {
    return UltraVerificationKey.verificationKeyHash();
  }

  function loadVerificationKey(
    uint256 vk,
    uint256 _omegaInverseLoc
  ) internal pure virtual override(BaseUltraVerifier) {
    UltraVerificationKey.loadVerificationKey(vk, _omegaInverseLoc);
  }
}
