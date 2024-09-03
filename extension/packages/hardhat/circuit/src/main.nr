use dep::std::hash::poseidon;
use dep::std::hash::keccak256;

fn main(
    index: Field,
    secret: Field,
    leaf: Field,
    root: pub [u8; 32],
    merkle_path: [[u8; 32]; 6],
    caller: Field,
    nullifier_hash: pub Field
) {
    assert(index as u16 < 64);
    assert(poseidon::bn254::hash_1([secret]) == leaf);
    check_nullifier(index, secret, caller, leaf, nullifier_hash);
    check_root(index, leaf, root, merkle_path);
}

fn check_nullifier(
    index: Field,
    secret: Field,
    caller: Field,
    leaf: Field,
    nullifier_hash: Field
) {
    assert(poseidon::bn254::hash_4([index, secret, caller, leaf]) == nullifier_hash);
}

fn check_root(index: Field, leaf: Field, root: [u8; 32], merkle_path: [[u8; 32]; 6]) {
    let mut temp: u8 = index as u8;
    let mut hash: [u8; 32] = leaf.to_be_bytes(32).as_array();
    for i in 0..6 {
        if (temp % 2 == 0) {
            hash = get_hash(hash, merkle_path[i]);
        } else {
            hash = get_hash(merkle_path[i], hash);
        };
        temp /= 2;
    }

    assert(hash == root);
}

fn get_hash(left: [u8; 32], right: [u8; 32]) -> [u8; 32] {
    let mut temp: [u8; 64] = [0; 64];
    for i in 0..32 {
        temp[i] = left[i];
        temp[i + 32] = right[i];
    }
    keccak256(temp, 64)
}

#[test]
fn test_main() {
    let index = 42;
    let secret: Field = 0x09a1cd8a2d612455bfa2fd076255d0977cd4bc2664d37d8f257386db6c5d4ee1;
    let leaf: Field = 0x0347f66a1af8de0bf995e5a0aa9cd250be2cd11745b590ecf697c680911f460c;
    let root: [u8; 32] = [
        246, 94, 204, 207, 237, 239, 226, 165,
        22, 67, 164, 112, 222,   3,  44, 182,
        231, 36, 163,   5, 111,  56, 217, 236,
        108, 10, 111,  52,  11,  70,  57, 195
    ];
    let merkle_path: [[u8; 32]; 6] = [
        [
            32, 184,  52, 115,  95, 220,  74, 128,
            203, 234,  48, 155, 192, 233, 160, 117,
            44, 114, 175, 119, 122,  52, 104, 164,
            243,  49, 176,  59,  23, 124, 131,  33
        ],
        [
            55,  48, 180, 241, 196, 173,  82, 206,
            196,  59,  25,  58,  83,  73,  89,  99,
            86, 158,  56, 247,  94, 132, 239, 237,
            226, 144, 137, 105,  19, 233, 133, 205
        ],
        [
            118, 235, 244,  6,   8, 119,  98, 238,
            210,  94, 214, 52, 111, 162, 123,  32,
            203, 138, 136, 30, 222, 214,  24,  51,
            116,  30, 138, 55, 175,  47,  81, 225
        ],
        [
            87,  56,  52, 18,  32,  61, 169,  75,
            46, 159, 139, 60, 237,  57,  55,  23,
            162,  95,  78, 75, 236, 116,  83,  96,
            228,  70, 160, 31,  17, 172,  43, 252
        ],
        [
            217, 203,  86, 106,  65, 161, 255,  52,
            141, 169, 156, 163, 109,  80,  77, 206,
            215,   3, 189, 225, 183,  36, 211,  34,
            25, 177, 196,  27, 243, 159, 128,  58
        ],
        [
            158,  22, 206,  39,  16, 231, 173,  19,
            156,  48,  42, 251,  12, 104, 167,  37,
            181, 117,  94,  91, 179,  17,  82, 232,
            208,  37, 145,  14, 226, 143, 166, 159
        ]
    ];
    let caller: Field = 0x1705ba2433147f2b4d2e028c20ade15a272c6053;
    let nullifier_hash: Field = 0x0d14e17bb38b66bdef8dcf523de38f37e010c45d99b50dd02f9c1543e6da4147;
    main(index, secret, leaf, root, merkle_path, caller, nullifier_hash);
}

#[test]
fn test_check_nullifier() {
    let index: Field = 13;
    let secret: Field = 0x16b91ee648fc191bc537eee03623497d37e2574290ee806e95a69db7e40a9927;
    let caller: Field = 0xf2bc1f275250bddbbd3c06226f95242ffdeb56b8;
    let leaf: Field = 0x2bf4c7c6071954d64c337fbe6133a61320a695c79923637076a7192ab530fffb;
    let nullifier_hash: Field = 0x294e37fa71b9941103153dd11f70763fe3532d65b2c0b61814671c3e3b43c9e2;
    check_nullifier(index, secret, caller, leaf, nullifier_hash);
}

#[test]
fn test_check_root() {
    let index: Field = 4;
    let leaf: Field = 0x165ffbf4ed5fdb53aef6653a44c5796797e4f62236647683c8876e113a6465ad;
    let root: [u8; 32] = [
        60, 149, 107, 195,  47,  28,  86,  66,
        164,   4, 129, 145,  93,  91, 198, 142,
        67,  82, 242, 249, 223, 229, 108,  58,
        136, 116, 165,   1, 108,  61, 252, 239
    ];

    let merkle_path: [[u8; 32]; 6] = [
        [
            40, 148, 119, 158, 238,  50, 118, 238,
            121,  93, 240,  60, 110, 143,  41, 116,
            90, 195, 221, 189,  77, 218, 111,  50,
            171, 113, 110,   2, 225,  61, 157, 251
        ],
        [
            95,  99, 166,  51,  23,  90, 126, 255,
            230, 149, 136,  19, 129,   8, 186, 100,
            196, 229, 109,  73, 171, 100, 178, 243,
            79, 227,  55, 231,  40, 115,  42, 175
        ],
        [
            244, 218, 201,  63,  16,  41, 211,  32,
            39, 128, 115, 121, 116, 200,  63, 234,
            44,  66,  38,  10, 118, 108,  89, 163,
            166, 245,  21, 206, 125, 240,  50, 116
        ],
        [
            154, 128, 144, 192, 216,  13,  73,
            1, 180, 171,  71,  68, 228, 102,
            193, 108, 169, 127, 111, 174,  15,
            196, 132,  62, 200, 133,  42, 130,
            188,  32, 174, 170
        ],
        [
            10,  82, 224, 122,  75, 195, 225, 128,
            128, 129,  20, 238, 213,  87,  35, 156,
            94, 243,  88,  14,  72,  20, 210, 245,
            147, 137, 114, 234, 116, 172, 187,  89
        ],
        [
            139,  14,  3, 122, 121, 142,  46,  40,
            168,  15, 49,  23, 244, 237,  49, 177,
            219, 179, 87, 115, 205, 107, 137, 240,
            220, 169, 55, 236, 179, 102,  48,  92
        ]
    ];

    check_root(index, leaf, root, merkle_path);
}

#[test]
fn test_get_hash() {
    let left: [u8; 32] =  [
        190,  46,  97, 174,  64, 221, 168,  60,
        104, 204, 147, 227,  15,  71, 118,  41,
        240, 161,  17, 187, 170,   5, 182, 100,
        247,  53,  45,   7, 244, 114, 139, 210
    ];
    let right: [u8; 32] = [
        153, 232, 112, 153,  45, 241,  76,
        102, 129, 248, 237, 104, 149, 208,
        38,   2, 175, 130, 161, 210, 190,
        244, 189,  92,  42,  18, 245, 198,
        127, 149,  13, 210
    ];
    let hash: [u8; 32] = [
        61, 200, 109, 247,   1, 237,  14, 250,
        7, 217,  81,  49, 196, 161,  60, 155,
        91, 235,   7,  77, 232, 207, 204, 107,
        251, 144, 133,  74,  42, 161,   7, 148
    ];

    assert(get_hash(left, right) == hash);
}
