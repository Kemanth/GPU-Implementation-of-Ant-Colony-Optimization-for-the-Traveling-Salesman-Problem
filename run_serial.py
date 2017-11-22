from os import system
from time import clock
import time
import pickle
import numpy as np

a = []
system('g++ serial2.cpp')
k=0
exec_time=[0]*9
start_time = time.time()
system('./a.out Graphs/bays29.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(29)

start_time = time.time()
system('./a.out Graphs/att48.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(48)

start_time = time.time()
system('./a.out Graphs/kroC100.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(100)

start_time = time.time()
system('./a.out Graphs/bier127.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(127)

start_time = time.time()
system('./a.out Graphs/kroB200.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(200)

start_time = time.time()
system('./a.out Graphs/lin318.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(318)

start_time = time.time()
system('./a.out Graphs/pr439.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(439)

start_time = time.time()
system('./a.out Graphs/pr1002.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(1002)

start_time = time.time()
system('./a.out Graphs/fnl4461.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1
a.append(4461)

objects = ['bays29', 'att48', 'kroc100', 'bier127', 'kroB200','lin318','pr439', 'pr1002', 'fnl4461']
y_pos = np.arange(len(objects))
 
with open("serialData.txt","wb") as inp:
	pickle.dump(a, inp)
	pickle.dump(exec_time, inp)
	pickle.dump(objects, inp)
