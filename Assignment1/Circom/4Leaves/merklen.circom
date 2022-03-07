pragma circom 2.0.0;

include "mimcsponge.circom";

template LeafHash() {
    signal input in;
    signal output out;
    //nInputs = 1, nOuts = 1, nRounds = 220
    component singleHash = MiMCSponge(1, 220, 1);

    //calculating hash of leaves
    singleHash.k <== 0;
    singleHash.ins[0] <== in;
    out <== singleHash.outs[0];
}

template NonLeafHash() {

    signal input left;
    signal input right;
    signal output hashedRoot;

    //nInputs = 2, nOuts = 1, nRounds = 220
    component hash = MiMCSponge(2, 220, 1);
    hash.k <== 0;
    hash.ins[0] <== left;
    hash.ins[1] <== right;
    hashedRoot <== hash.outs[0];

}

template MerkleHelper(N) {

    var totNodes = 2 * N - 1; 
    //input-list of N leaves, output-Merkle root
    signal input leaves[N]
    signal output nodes[totNodes]; //to store all the hashes in Merkle Tree

    component leavesHash[N]; //to store the hashes of leaves
    component nonLeavesHash[N-1]; //to store the hashes of non-leaves nodes 

    //instantiate leavesHash and getting the hashes of leaves
    var x = totNodes \ 2; 
    for(var i = 0; i < N; i++){ 
        leavesHash[i] = LeafHash();
        leavesHash[i].in <== leaves[i];
        var a = leavesHash[i].out;
        nodes[x] <== leavesHash[i].out; // storing hashes starting from the back of the nodes array i.e.
        //node[0] will have the Merkle root
        x++;
    }

    //instantiate nonLeavesHash
    for(var i = 0; i< N-1; i++){
        nonLeavesHash[i] = NonLeafHash();
    }

    for(var i = totNodes \ 2 - 1; i >= 0; i--){ 
        nonLeavesHash[i].left <== nodes[2*i+1]; // input of left node with hash
        nonLeavesHash[i].right <== nodes[2*i+2]; // input of right node with hash
        nodes[i] <== nonLeavesHash[i].hashedRoot; //updating the calculated hash
    }

}

template MerkleN(N) {

    //for getting root as output
    signal input list[N]; 
    signal output root; 

    var totNodes = 2 * N - 1; 
    component hashedNodes = MerkleHelper(N);

    for(var i =0; i<N; i++){
        hashedNodes.leaves[i] <== list[i];
    }

    root <== hashedNodes.nodes[0];
}

component main {public [list]} = MerkleN(4);