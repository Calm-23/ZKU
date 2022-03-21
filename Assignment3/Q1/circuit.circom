pragma circom 2.0.0;

include "util.circom";

//This calculates the distance between the two points, given by source, s and destination, d
template calculateDistance(){
    signal input s[2];
    signal input d[2];
    signal output totalDist;

    signal distX;
    signal distY;
    signal distXSq;
    signal distYSq;

    distX <== d[0] - s[0];
    distXSq <== distX * distX;
    distY <== d[1] - s[1];
    distYSq <== distY * distY;

    //total distance = x^2 + y^2
    totalDist <== distXSq + distYSq;
}

//This calculates the area of the triangle of the points A, B, C
template calculateArea(){
    signal input a[2];
    signal input b[2];
    signal input c[2];
    signal output area;

    signal A;
    A <== a[0] * (b[1] - c[1]) ;
    signal B;
    B <== b[0] * (c[1] - a[1]);
    signal C;
    C <== c[0] * (a[1] - b[1]);
    
    area <== A + B + C;
}

//This checks if energy is enough for the jump between the two points
template checkEnergyBound(){

    signal input s[2];
    signal input d[2];
    signal input E;
    signal output out;

    signal energyLimit;
    energyLimit <== E ** 2;

    signal jump;
    component dist = calculateDistance();
    dist.s[0] <== s[0];
    dist.s[1] <== s[1];
    dist.d[0] <== d[0];
    dist.d[1] <== d[1];
    jump <== dist.totalDist;

    //The output is 1 in case the jumpDist <= Energy
    component isValid = LessEqThan(32);
    isValid.in[0] <== jump;
    isValid.in[1] <== energyLimit;
    out <== isValid.out;

    //constraint for the valid move
    out === 1;
}

template Main() {
    signal input a[2];
    signal input b[2];
    signal input c[2];
    signal input energy;

    signal output validMove;

    component getArea = calculateArea();
    getArea.a[0] <== a[0];
    getArea.a[1] <== a[1];
    getArea.b[0] <== b[0];
    getArea.b[1] <== b[1];
    getArea.c[0] <== c[0];
    getArea.c[1] <== c[1];

    signal area;
    area <== getArea.area;
    
    //checking if the given points lie on a triangular path
    //if area of triangle = 0, then points don't lie on a triangle
    signal triangleAreaIsZero;
    component checkIfArea = IsZero();
    checkIfArea.in <== area;

    //the output is 1 if the area of the triangle is zero
    triangleAreaIsZero <== checkIfArea.out;
    
    //constraint for the validity of the triangle jump.
    triangleAreaIsZero === 0;

    signal jumpAB;
    signal jumpBC;

    //output is 1 if the jump from A to B is valid
    component isValidMove1 = checkEnergyBound();
    isValidMove1.s[0] <== a[0];
    isValidMove1.s[1] <== a[1];
    isValidMove1.d[0] <== b[0];
    isValidMove1.d[1] <== b[1];
    isValidMove1.E <== energy;
    jumpAB <== isValidMove1.out;

    //output is 1 if the jump from B to C is valid.
    component isValidMove2 = checkEnergyBound();
    isValidMove2.s[0] <== b[0];
    isValidMove2.s[1] <== b[1];
    isValidMove2.d[0] <== c[0];
    isValidMove2.d[1] <== c[1];
    isValidMove2.E <== energy;
    jumpBC <== isValidMove2.out;

    //constraints to check the validity of the jumps
    //from A to B and B to C
    jumpAB === 1;
    jumpBC === 1;

    //the circuit throws an error if all the above three constraints
    //are not satisfied, hence in the end the ouput will be 1 in the 
    //case all the constraints are satisfied and the triangle jump move is 
    //valid.
    validMove <== 1;
}

component main = Main();
