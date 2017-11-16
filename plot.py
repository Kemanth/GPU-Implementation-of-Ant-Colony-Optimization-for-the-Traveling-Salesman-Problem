
# coding: utf-8

# In[1]:


from matplotlib import pyplot as plt


# In[3]:


import pickle


# In[4]:


with open('example.in', 'rb') as inp:
    xLabel = pickle.load(inp)
    a = pickle.load(inp)
    exec_time = pickle.load(inp)


# In[30]:


with open('example2.in', 'rb') as inp:
    xLabel1 = pickle.load(inp)
    a1 = pickle.load(inp)
    exec_time1 = pickle.load(inp)


# In[44]:


get_ipython().magic('matplotlib inline')
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

