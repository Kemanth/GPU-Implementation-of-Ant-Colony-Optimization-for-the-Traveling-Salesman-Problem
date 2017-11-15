from os import *
from time import clock
import time


k=0
exec_time=[0]*8
system('nvcc -c "-D MAX_ANTS=29" "-D MAX_CITIES=29" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/bays29.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('nvcc -c "-D MAX_ANTS=48" "-D MAX_CITIES=48" parallel_ants2.cu')
system('./a.out Graphs/att48.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=100" "-D MAX_CITIES=100" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/kroC100.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=107" "-D MAX_CITIES=107" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/pr107.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=127" "-D MAX_CITIES=127" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/bier127.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=200" "-D MAX_CITIES=200" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/kroB200.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=318" "-D MAX_CITIES=318" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/lin318.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

system('nvcc -c "-D MAX_ANTS=439" "-D MAX_CITIES=439" parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/pr439.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1



