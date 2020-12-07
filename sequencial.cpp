%%cu
#include <cuda.h>
#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

#define TAM 6000
#define escalar 35

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
    auto startTotal = high_resolution_clock::now();
    cout << "Starting..." << endl;

    cout << "Initializing elements..." << endl;
    auto start = high_resolution_clock::now();
    initialization();
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << "Time: " << duration.count() / 1000000.0 << " seconds" << endl;

    cout << endl << "( C = A + B ) - Adding matrix A and B and storing in C..." << endl;
    auto start1 = high_resolution_clock::now();
    someMatrix();
    auto stop1 = high_resolution_clock::now();
    auto duration1 = duration_cast<microseconds>(stop1 - start1);
    cout << "Time: " << duration1.count() / 1000000.0 << " seconds" << endl;
    // printC();

    cout << endl << "( D = A * B ) - Multiply matrix A and B and storing in D..." << endl;
    auto start2 = high_resolution_clock::now();
    multiplyMatrix();
    auto stop2 = high_resolution_clock::now();
    auto duration2 = duration_cast<microseconds>(stop2 - start2);
    cout << "Time: " << duration2.count() / 1000000.0 << " seconds" << endl;
    // printD();

    cout << endl << "( A = A * "<< escalar <<" ) - Multiply matrix A and escalar and storing in A..." << endl;
    auto start3 = high_resolution_clock::now();
    multiplyMatrixPerEscalar();
    auto stop3 = high_resolution_clock::now();
    auto duration3 = duration_cast<microseconds>(stop3 - start3);
    cout << "Time: " << duration3.count() / 1000000.0 << " seconds" << endl;
    // printA();

    cout << endl << "( VET = V * B ) - Multiply matrix B and vector C and storing in VET..." << endl;
    auto start4 = high_resolution_clock::now();
    multiplyMatrixPerVector();
    auto stop4 = high_resolution_clock::now();
    auto duration4 = duration_cast<microseconds>(stop4 - start4);
    cout << "Time: " << duration4.count() / 1000000.0 << " seconds" << endl;
    // printVET();

    auto stopTotal = high_resolution_clock::now();
    auto durationTotal = duration_cast<microseconds>(stopTotal - startTotal);
    cout << "\n--------------------------------------------------" << endl;
    cout << "Total algorithm time: " << durationTotal.count() / 1000000.0 << " seconds" << endl;

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
