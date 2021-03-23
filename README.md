# ppd trabalho cuda
Trabalho consiste na implementação de quatro operações utilizando o recurso CUDA: Soma
entre matrizes; Multiplicação entre matrizes; Multiplicação de matriz por escalar e por fim,
multiplicação de matriz por vetor.

## Motivação
O trabalho tem como motivação aprofundar os conhecimentos em CUDA através de uma avaliação para a matéria de Processamento Paralelo e Distribuído - 2020

## Definição
A implementação consistiu em 5 etapas, sendo elas: A inicialização das matrizes diretamente na memória da GPU (o que permitiu uma redução de tempo em comparação à inicialização na memória principal), e as 4 operações.

## Configurações utilizadas na execução do programa
* Para as operações de matrizes, optou-se por utilizar 32x32 threads, totalizando 1.024,
em 188x188 blocos, totalizando 35.344 blocos. Portanto, o programa foi executado 36.192.256 vezes. 
* Para a operação de vetor, utilizou-se 1.024 threads em 6 blocos. Portanto, o programa
foi executado 6.144 vezes.

## Resultados com dimensões 6000:
|             |Sequencial | CUDA |
|------------|------------|-------------|
M + M | 0,1116148 | 0,1020826
M * M | 2649,948 | 0,8893174
M * e | 0,1006962 | 0,096894
V * M | 0,1085582 | 0,0007024
**Total** | **2650,904** | **1,22823**

Média de tempo em segundos com 5 execuções. O “total” corresponde ao tempo de execução
das 4 operações, mais a inicialização das matrizes e demais fatores do algoritmo.

## Ambiente de execução
O algoritmo foi executado no ambiente de [colab](https://colab.research.google.com/). As configurações do ambiente no momento
dos testes: 
* GPU: Nvidia Tesla T4, VRAM: 15079 MB
* CPU: Intel(R) Xeon(R) CPU @ 2.20GHz
* RAM: 14000 MB.

## Conclusão
O paralelismo utilizando a GPU apresentou uma redução significativa no tempo de execução em relação a implementação sequencial. O maior destaque fica para a operação de multiplicação entre matrizes, o qual resultou em um ganho de tempo (nas dimensões de 6000) de 297.975,50%, as demais operações também apresentaram ótimo um ganho de tempo: M+M = 109,33%; M*e = 103,92%; V*M = 15.455,32% e o Total = 215.831,23%.

Diante dos dados analíticos apresentados, pode-se afirmar que o paralelismo através da GPU explorado no algoritmo, apresentou ótimos resultados no tempo de execução em relação a implementação sequencial.
