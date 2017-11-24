
from matplotlib import pyplot as plt
import numpy as np
import pickle
from math import *


with open('serialData.txt', 'r') as inp:
    
    a = pickle.load(inp)
    exec_time = pickle.load(inp)
    xLabel = pickle.load(inp)
    ex = np.array(exec_time)
#exec_time = [log10(x) for x in exec_time]

# In[30]:


with open('parallelData.txt', 'r') as inp1:
    
    a1 = pickle.load(inp1)
    exec_time1 = pickle.load(inp1)
    xLabel1 = pickle.load(inp1)
    ex1 = np.array(exec_time1)
a = [log10(x) for x in a]
speedup = ex / ex1 
print(speedup)
print(exec_time)
print(exec_time1)
#exec_time1 = [log10(x) for x in exec_time1]


# In[44]:

##fig = plt.figure()
##ax = fig.add_subplot(111)

plt.title('Parallel vs Serial speedup')
plt.xlabel('Cities', color = 'blue')
plt.ylabel('Speedup factor', color = 'blue')

plt.plot(a, speedup, 'ro')
plt.plot(a, speedup, color = 'red' )
plt.legend()
plt.xticks(a, xLabel, fontsize = 8)
#plt.yticks(exec_time, ex, fontsize = 4)

# In[34]:
##for a, b in zip(a, exec_time):
##    ax.annotate(str(int(b)), xy = (a, b))

plt.show()

