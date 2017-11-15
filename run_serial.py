from os import *
from time import clock
import time
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt

system('g++ serial_ants.cpp')
k=0
exec_time=[0]*8
start_time = time.time()
system('./a.out Graphs/bays29.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/att48.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/kroc100.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/pr107.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/bier127.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/kroB200.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/lin318.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

start_time = time.time()
system('./a.out Graphs/pr439.tsp')
print("--- %s seconds ---" % (time.time() - start_time))
exec_time[k]=time.time() - start_time
k+=1

objects = ('bays29', 'att48', 'kroc100', 'pr107', 'bier127', 'kroB200','lin318','pr439')
y_pos = np.arange(len(objects))
 
plt.bar(y_pos, exec_time, align='center', alpha=0.5)
plt.xticks(y_pos, objects)
plt.ylabel('Time in seconds')
plt.title('Execution time for different graphs in TSPLIB')
plt.savefig('graph.png')
plt.show()
