import tensorflow as tf
import extract_data
import one_hot_encoder
import numpy as np
import matplotlib.pyplot as plt

sess = tf.InteractiveSession()

# 输入样本向量的大小
x_size = 16*16
# 输入类标向量的大小
label_size = 62
# 二位灰度图像的大小
image_width = 16
image_high = 16
image_channel = 1
# 卷积网络相关参数
kernel_size = 5
conv1_features = 32
conv2_features = 64
ac_nodes = 1024
softmax_out = 62


# 初始化权重
def weight_variable(shape):
    # using truncated_normal to create weight variable which obeys the truncated normal(standard deviation: 0.1)
    # initial is a tensor
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)


# 初始化偏置
def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)


# 卷积层创建函数　x:卷积层的输入　W:卷积的参数　
# 　　　　　　　　　　　　　　　　　[5,5,1,32]:前两个数代表卷积核的尺寸　第三个数代表通道数　32代表卷积核的数量,即提取多少种特征
def conv2d(x1, w):
    return tf.nn.conv2d(x1, w, strides=[1, 1, 1, 1], padding='SAME')


# 池化层创建函数
def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

# 定义输入的placeholder　x为特征,为二维图片,y_为真实类标
x = tf.placeholder(tf.float32, [None, x_size])
y_ = tf.placeholder(tf.float32, [None, label_size])
# [-1,28,28,1] -1代表样本数量不固定,28 28为尺寸　1表示颜色通道
x_image = tf.reshape(x, [-1, image_width, image_high, image_channel])

# 定义卷积层１
W_conv1 = weight_variable([kernel_size, kernel_size, image_channel, conv1_features])
b_conv1 = bias_variable([conv1_features])
h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)

W_conv2 = weight_variable([kernel_size, kernel_size, conv1_features, conv2_features])
b_conv2 = bias_variable([conv2_features])
h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
h_pool2 = max_pool_2x2(h_conv2)

# 将第二层卷积层的输出变形为一维向量　输入到全连接层　最后用relu函数激活
W_fc1 = weight_variable([4 * 4 * conv2_features, ac_nodes])
b_fc1 = bias_variable([ac_nodes])
h_pool2_flat = tf.reshape(h_pool2, [-1, 4 * 4 * conv2_features])
h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

# 使用dropout层降低参数　从而减轻过拟合
keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

# 将dropout连接至SOFTMAX　得到概率输出
W_fc2 = weight_variable([ac_nodes, softmax_out])
b_fc2 = bias_variable([softmax_out])
y_out = tf.matmul(h_fc1_drop, W_fc2) + b_fc2

# 定义损失函数　用于模型评估
cross_entropy = tf.nn.softmax_cross_entropy_with_logits(logits=y_out, labels=y_)
# cross_entropy = tf.reduce_mean(y_ * tf.log(tf.clip_by_value(y_out, 1e-10, 1.0)), reduction_indices=[1])
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)

# 定义评测准确率的操作
correct_prediction = tf.equal(tf.argmax(y_out, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

# 开始训练
# 还需要完成训练数据和测试数据的划分。
tf.global_variables_initializer().run()
coord = tf.train.Coordinator()
threads = tf.train.start_queue_runners(sess=sess, coord=coord)
for i in range(10000):
    image_train, label_train = sess.run([extract_data.image_batch_train, extract_data.label_batch_train])
    # print(type(image_train[0][0]))
    # for l in range(np.shape(label_train)[0]):
    #     print(chr(label_train[l]))
    label_train = one_hot_encoder.array_fit(label_train)
    # print(label_train[0])
    # for j in range(np.shape(image_train)[0]):
    #     plt.imshow(np.reshape(image_train[j], [16, 16]))
    #     plt.show()
    # print(np.shape(image_train))
    # print(label_train)
    if i % 100 == 0:
        print(y_out.eval(feed_dict={x: image_train, y_: label_train, keep_prob: 1.0}))
        train_accuracy = accuracy.eval(feed_dict={x: image_train, y_: label_train, keep_prob: 1.0})
        print("step %d, training accuracy %g"%(i, train_accuracy))
    train_step.run(feed_dict={x: image_train, y_: label_train, keep_prob: 0.5})

image_test, label_test = sess.run([extract_data.image_batch_test, extract_data.label_batch_test])
label_test = one_hot_encoder.array_fit(label_test)
# print("test accuracy %g"%accuracy.eval(feed_dict={x: image_test, y_: label_test,
#                                                   keep_prob: 1}))
coord.clear_stop()
coord.join(threads)




