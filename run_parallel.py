from os import system
from time import clock
import time
import pickle
import numpy as np

a = []
k=0
exec_time=[0]*9
system('nvcc -D MAX_ANTS=29 -D MAX_CITIES=29 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/bays29.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(29)

start_time = time.time()
system('nvcc -D MAX_ANTS=48 -D MAX_CITIES=48 parallel_ants2.cu')
system('./a.out Graphs/att48.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(48)

system('nvcc -D MAX_ANTS=100 -D MAX_CITIES=100 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/kroC100.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(100)


system('nvcc -D MAX_ANTS=127 -D MAX_CITIES=127 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/bier127.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(127)

system('nvcc -D MAX_ANTS=200 -D MAX_CITIES=200 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/kroB200.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(200)

system('nvcc -D MAX_ANTS=318 -D MAX_CITIES=318 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/lin318.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(318)

system('nvcc -D MAX_ANTS=439 -D MAX_CITIES=439 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/pr439.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(439)

system('nvcc -D MAX_ANTS=1002 -D MAX_CITIES=1002 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/pr1002.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(1002)

system('nvcc -D MAX_ANTS=4461 -D MAX_CITIES=4461 parallel_ants2.cu')
start_time = time.time()
system('./a.out Graphs/fnl4461.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(4461)
	
objects = ['bays29', 'att48', 'kroc100', 'bier127', 'kroB200','lin318','pr439', 'pr1002', 'fnl4461']
y_pos = np.arange(len(objects))
with open("parallelData.txt", "wb") as inp:
	pickle.dump(a, inp)
	pickle.dump(exec_time, inp)
	pickle.dump(objects, inp)
