from sklearn.preprocessing import OneHotEncoder
import numpy as np


def array_fit(array):
    n = np.size(array)
    array_return = np.zeros([n, 62])
    for m in range(n):
        array_return[m, :] = enc.transform(array[m]).toarray()
    return array_return

# 将0~9转换为ascall码存入数组a中
a = np.zeros([62, 1])
for i in range(ord('9')-ord('0')+1):
    a[i][0] = ord('0') + i
# 将A~Z转换为ascall码存入数组a中
for j in range(ord('Z')-ord('A')+1):
    a[j+ord('9')-ord('0')+1][0] = ord('A') + j
# 将a~z转换为ascall码存入数组a中
for j in range(ord('z')-ord('a')+1):
    a[j+ord('9')-ord('0')+1+ord('Z')-ord('A')+1][0] = ord('a') + j
# 依据数组a进行one-hot编码
enc = OneHotEncoder()
enc.fit(a)



