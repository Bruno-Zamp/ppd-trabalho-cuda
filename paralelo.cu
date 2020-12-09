/*
    Autor: Bruno de Almeida Zampirom
    Trabalho de implementação de operações sobre matrizes utilizando CUDA

    **Obs: Para printar o valor das matrizes descomentar funções printVET(), printA(), printD(), printVET() nas linhas 89, 98, 107 e 116.
*/
#include <iostream>
#include <cuda.h>
#include <chrono>

using namespace std;
using namespace std::chrono;

#define TAM 6000
#define escalar 35.5

#define THREADSPERBLOCK 1024
#define BLOCKSPERGRID 188

float A[TAM][TAM], B[TAM][TAM], C[TAM][TAM], D[TAM][TAM], V[TAM], VET[TAM];

float *d_A, *d_B, *d_C, *d_D, *d_V, *d_VET;
size_t size, size_vec;

void printA();
void printC();
void printD();
void printVET();
__global__ void initializationVarCUDA(float *A, float *B, float *C, float *D, float *V, float *VET, int N);
__global__ void multiplyMatrix(float *A, float *B, float *D, int N);
__global__ void multiplyMatrixPerVector(float *B, float *V, float *VET, int N);
__global__ void multiplyMatrixPerEscalar(float *A, int N);
__global__ void someMatrix(float *A, float *B, float *C, int N);

int main()
{
    auto startTotal = high_resolution_clock::now();
    cout << "Starting..." << endl;

    size = TAM * TAM * sizeof(float);
    size_vec = TAM * sizeof(float);

    dim3 threadsPerBlock(32, 32);
    dim3 blocksPerGrid(BLOCKSPERGRID, BLOCKSPERGRID);

    cout << "Initializing CUDA variables..." << endl;
    auto start = high_resolution_clock::now();

    if (cudaMalloc((void**)&d_A, size) != cudaSuccess)
        printf("Erro de alocação do vetor d_A\n");
    if (cudaMalloc((void**)&d_B, size) != cudaSuccess)
        printf("Erro de alocação do vetor d_B\n");
    if (cudaMalloc((void**)&d_C, size) != cudaSuccess)
        printf("Erro de alocação do vetor d_C\n");
    if (cudaMalloc((void**)&d_D, size) != cudaSuccess)
        printf("Erro de alocação do vetor d_D\n");
    if (cudaMalloc((void**)&d_V, size_vec) != cudaSuccess)
        printf("Erro de alocação do vetor d_V\n");
    if (cudaMalloc((void**)&d_VET, size_vec) != cudaSuccess)
        printf("Erro de alocação do vetor d_VET\n");

    initializationVarCUDA<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, d_D, d_V, d_VET, TAM);

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << "Time: " << duration.count() / 1000000.0 << " seconds" << endl;

    printf("\nN: %d\nBlocos: %d\nThreads: %d\n", TAM*TAM, (BLOCKSPERGRID * BLOCKSPERGRID), THREADSPERBLOCK);

    cout << endl << "( C = A + B ) - Adding matrix A and B and storing in C..." << endl;
    auto start1 = high_resolution_clock::now();
    someMatrix<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, TAM);
    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
    auto stop1 = high_resolution_clock::now();
    auto duration1 = duration_cast<microseconds>(stop1 - start1);
    cout << "Time: " << duration1.count() / 1000000.0  << " seconds" << endl;
    // printC();

    cout << endl << "( D = A * B ) - Multiply matrix A and B and storing in D..." << endl;
    auto start2 = high_resolution_clock::now();
    multiplyMatrix<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_D, TAM);
    cudaMemcpy(D, d_D, size, cudaMemcpyDeviceToHost);
    auto stop2 = high_resolution_clock::now();
    auto duration2 = duration_cast<microseconds>(stop2 - start2);
    cout << "Time: " << duration2.count() / 1000000.0  << " seconds" << endl;
    // printD();

    cout << endl << "( A = A * "<< escalar <<" ) - Multiply matrix A and escalar and storing in A..." << endl;
    auto start3 = high_resolution_clock::now();
    multiplyMatrixPerEscalar<<<blocksPerGrid, threadsPerBlock>>>(d_A, TAM);
    cudaMemcpy(A, d_A, size, cudaMemcpyDeviceToHost);
    auto stop3 = high_resolution_clock::now();
    auto duration3 = duration_cast<microseconds>(stop3 - start3);
    cout << "Time: " << duration3.count() / 1000000.0 << " seconds" << endl;
    // printA();

    cout << endl << "( VET = V * B ) - Multiply matrix B and vector C and storing in VET..." << endl;
    auto start4 = high_resolution_clock::now();
    multiplyMatrixPerVector<<<THREADSPERBLOCK, BLOCKSPERGRID>>>(d_B, d_V, d_VET, TAM);
    cudaMemcpy(VET, d_VET, size_vec, cudaMemcpyDeviceToHost);
    auto stop4 = high_resolution_clock::now();
    auto duration4 = duration_cast<microseconds>(stop4 - start4);
    cout << "Time: " << duration4.count() / 1000000.0 << " seconds" << endl;
    // printVET();

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    cudaFree(d_D);
    cudaFree(d_VET);
    cudaFree(d_V);

    auto stopTotal = high_resolution_clock::now();
    auto durationTotal = duration_cast<microseconds>(stopTotal - startTotal);
    cout << "\n--------------------------------------------------" << endl;
    cout << "Total algorithm time: " << durationTotal.count() / 1000000.0 << " seconds" << endl;

    return 0;
}

__global__ void multiplyMatrixPerEscalar(float *A, int N) {
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    if (row < N && col < N) {
        A[row * N + col] *= escalar;
    }
}

// Multiplying matrix A and B and storing in C.
__global__ void multiplyMatrix(float *A, float *B, float *D, int N) {
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    float tmpSum = 0;
    if (row < N && col < N) {
        for (int i = 0; i < N; i++) {
            tmpSum += A[row * N + i] * B[i * N + col];
        }
        D[row * N + col] = tmpSum;
    }
}

// Multiplying matrix A and B and storing in C.
__global__  void multiplyMatrixPerVector(float *B, float *V, float *VET, int N) {
    int tid = blockIdx.x*blockDim.x+threadIdx.x;

    float tmpSum = 0;
    if (tid < N) {
        for (int i = 0; i < N; i++) {
            tmpSum += V[i] * B[i * N + tid];
        }
        VET[tid] = tmpSum;
    }
}

// Adding matrix A and B and storing in C.
__global__ void someMatrix(float *A, float *B, float *C, int N) {
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;

    if (row < N && col < N) {
        C[row * N + col] = A[row * N + col] + B[row * N + col];
    }
}

__global__ void initializationVarCUDA(float *A, float *B, float *C, float *D, float *V, float *VET, int N) {
    int row = blockIdx.y*blockDim.y+threadIdx.y;
    int col = blockIdx.x*blockDim.x+threadIdx.x;
    if (row < N && col < N) {
        A[row * N + col] = row + col;
        B[row * N + col] = row + col;
        C[row * N + col] = 0;
        D[row * N + col] = 0;
        V[row] = row;
        VET[row] = 0;
    }
}

// Displaying the C matrix.
void printC() {
    bool teste = false;
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        if (i > 0 && j > 0 && C[i][j] == 0) teste = true;
        cout << " " << C[i][j];
        if(j == TAM-1)
            cout << endl;
    }

    if(teste) printf("Ocorreu um erro!");
}

// Displaying the D matrix.
void printD() {
    bool teste = false;
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        if (i > 0 && j > 0 && D[i][j] == 0) teste = true;
        cout << " " << D[i][j];
        if(j == TAM-1)
            cout << endl;
    }
    if(teste) printf("Ocorreu um erro!");
}

// Displaying the A matrix.
void printA() {
    bool teste = false;
    for(int i = 0; i < TAM; ++i)
    for(int j = 0; j < TAM; ++j)
    {
        if (i > 0 && j > 0 && A[i][j] == 0) teste = true;
        cout << " " << A[i][j];
        if(j == TAM-1)
            cout << endl;
    }
    if(teste) printf("Ocorreu um erro!");
}

// Displaying the VET vector.
void printVET() {
    bool teste = false;
    for(int i = 0; i < TAM; ++i) {
        if (i > 0 && VET[i] == 0) teste = true;
        cout << " " << VET[i];
    }
    cout << endl;
    if(teste) printf("Ocorreu um erro!");
}
