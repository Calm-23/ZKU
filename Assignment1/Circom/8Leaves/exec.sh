#! /bin/sh
circom merklen.circom --r1cs --wasm --sym --c --json
node merklen_js/generate_witness.js merklen_js/merklen.wasm input.json witness.wtns

snarkjs powersoftau new bn128 15 pot12_0000.ptau
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup merklen.r1cs pot12_final.ptau merklen_0000.zkey
snarkjs zkey contribute merklen_0000.zkey merklen_0001.zkey --name="Mansi" -v
snarkjs zkey export verificationkey merklen_0001.zkey verification_key.json

snarkjs groth16 prove merklen_0001.zkey witness.wtns proof.json public.json

snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs zkey export solidityverifier merklen_0001.zkey verifier.sol

snarkjs generatecall
