
from matplotlib import pyplot as plt

import pickle



with open('serialData.txt', 'rb') as inp:
    
    a = pickle.load(inp)
    exec_time = pickle.load(inp)
    xLabel = pickle.load(inp)


# In[30]:


with open('parallelData.txt', 'rb') as inp1:
    
    a1 = pickle.load(inp1)
    exec_time1 = pickle.load(inp1)
    xLabel1 = pickle.load(inp1)


# In[44]:


#get_ipython().magic('matplotlib inline')
plt.title('Parallel vs Serial execution comparison')
plt.xlabel('Cities', color = 'blue')
plt.ylabel('execution time', color = 'blue')

plt.plot(a, exec_time, 'ro')
plt.plot(a, exec_time, label = 'serial', color = 'red')
plt.plot(a1, exec_time1, 'bo')
plt.plot(a1, exec_time1, label = 'parallel', color = 'blue')
plt.legend()
plt.xticks(a, xLabel)
ex = [int(x) for x in exec_time]
plt.yticks(exec_time, ex)


# In[34]:


plt.show()

