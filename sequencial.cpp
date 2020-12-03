#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

#define TAM 1000
#define escalar 35.5

float A[TAM][TAM], B[TAM][TAM], C[TAM][TAM], D[TAM][TAM], V[TAM], VET[TAM];

void initialization();
void printA();
void printC();
void printD();
void printVET();
void multiplyMatrix();
void multiplyMatrixPerVector();
void multiplyMatrixPerEscalar();
void someMatrix();

int main()
{
    cout << "Starting..." << endl;

    cout << "Initializing elements..." << endl;
    initialization();

    cout << endl << "( C = A + B ) - Adding matrix A and B and storing in C..." << endl;
    auto start1 = high_resolution_clock::now();
    someMatrix();
    auto stop1 = high_resolution_clock::now();
    auto duration1 = duration_cast<seconds>(stop1 - start1);
    cout << "Time: " << duration1.count() << " seconds" << endl;
    // cout << endl << "Result C: " << endl;
    // printC();

    cout << endl << "( D = A * B ) - Multiply matrix A and B and storing in D..." << endl;
    auto start2 = high_resolution_clock::now();
    multiplyMatrix();
    auto stop2 = high_resolution_clock::now();
    auto duration2 = duration_cast<seconds>(stop2 - start2);
    cout << "Time: " << duration2.count() << " seconds" << endl;
    // cout << endl << "Result D: " << endl;
    // printD();

    cout << endl << "( A = A * "<< escalar <<" ) - Multiply matrix A and escalar and storing in A..." << endl;
    auto start3 = high_resolution_clock::now();
    multiplyMatrixPerEscalar();
    auto stop3 = high_resolution_clock::now();
    auto duration3 = duration_cast<seconds>(stop3 - start3);
    cout << "Time: " << duration3.count() << " seconds" << endl;
    // cout << endl << "Result A: " << endl;
    // printA();

    cout << endl << "( VET = V * B ) - Multiply matrix B and vector C and storing in VET..." << endl;
    auto start4 = high_resolution_clock::now();
    multiplyMatrixPerVector();
    auto stop4 = high_resolution_clock::now();
    auto duration4 = duration_cast<seconds>(stop4 - start4);
    cout << "Time: " << duration4.count() << " seconds" << endl;
    // cout << endl << "Result VET: " << endl;
    // printVET();

    return 0;
}

void multiplyMatrixPerEscalar() {
    for(int i = 0; i < TAM; ++i)
        for(int j = 0; j < TAM; ++j)
            A[i][j]*= escalar;
}

// Multiplying matrix A and B and storing in C.
void multiplyMatrix() {
    for(int i = 0; i < TAM; ++i)
        for(int j = 0; j < TAM; ++j)
            for(int k = 0; k < TAM; ++k)
            {
                D[i][j] += A[i][k] * B[k][j];
            }
}

// Multiplying matrix A and B and storing in C.
void multiplyMatrixPerVector() {
    for (int i = 0; i < TAM; ++i)
        for (int j=0; j < TAM; j++)
            VET[i]+= B[i][j] * V[j];
}

// Adding matrix A and B and storing in C.
void someMatrix() {
    for(int i = 0; i < TAM; ++i)
        for(int j = 0; j < TAM; ++j)
            C[i][j] = A[i][j] + B[i][j];
}

void initialization() {
    for(int i = 0; i < TAM; ++i)
        for(int j = 0; j < TAM; ++j)
        {
            A[i][j] = i + j;
            B[i][j] = i + j;
            C[i][j] = 0;
            D[i][j] = 0;
            V[i] = i;
            VET[i] = 0;
        }
}

// Displaying the C matrix.
void printC() {
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        cout << " " << C[i][j];
        if(j == TAM-1)
            cout << endl;
    }
}

// Displaying the D matrix.
void printD() {
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        cout << " " << D[i][j];
        if(j == TAM-1)
            cout << endl;
    }
}

// Displaying the A matrix.
void printA() {
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        cout << " " << A[i][j];
        if(j == TAM-1)
            cout << endl;
    }
}

// Displaying the VET vector.
void printVET() {
    for(int i = 0; i < TAM; ++i)
        cout << " " << VET[i];
}
