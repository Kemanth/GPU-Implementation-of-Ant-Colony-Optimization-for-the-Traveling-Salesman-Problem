
from matplotlib import pyplot as plt

import pickle
from math import *


with open('serialData.txt', 'r') as inp:
    
    a = pickle.load(inp)
    exec_time = pickle.load(inp)
    xLabel = pickle.load(inp)
a = [log10(x) for x in a]
#exec_time = [log10(x) for x in exec_time]

# In[30]:


with open('parallelData.txt', 'r') as inp1:
    
    a1 = pickle.load(inp1)
    exec_time1 = pickle.load(inp1)
    xLabel1 = pickle.load(inp1)
a1 = [log10(x) for x in a1]
#exec_time1 = [log10(x) for x in exec_time1]


# In[44]:

##fig = plt.figure()
##ax = fig.add_subplot(111)

#get_ipython().magic('matplotlib inline')
plt.title('Parallel vs Serial execution comparison')
plt.xlabel('log of number of Cities', color = 'blue')
plt.ylabel('execution time', color = 'blue')

plt.plot(a, exec_time, 'ro')
plt.plot(a, exec_time, label = 'serial', color = 'red')
plt.plot(a1, exec_time1, 'bo')
plt.plot(a1, exec_time1, label = 'parallel', color = 'blue')
plt.legend()
plt.xticks(a, xLabel, fontsize = 8)
ex = [int(x) for x in exec_time]
#plt.yticks(exec_time, ex, fontsize = 4)

# In[34]:
##for a, b in zip(a, exec_time):
##    ax.annotate(str(int(b)), xy = (a, b))

plt.show()

