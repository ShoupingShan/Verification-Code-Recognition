import tensorflow as tf
import numpy as np
import one_hot_encoder
import matplotlib.pyplot as plt

# 定义解析TFRecord文件操作
reader = tf.TFRecordReader()
filename_queue = tf.train.string_input_producer(["/home/mxqian/Projects/Captcha/captcha_data/Records/"
                                                 "captcha_data_train.tfrecords"])

_, serialized_example = reader.read(filename_queue)
features_train = tf.parse_single_example(
    serialized_example,
    features={
        'data': tf.FixedLenFeature([], tf.string),
        'label': tf.FixedLenFeature([], tf.int64)
    })

image_train = features_train['data']
label_train = features_train['label']

# 组合训练数据
# 每个batch中样本量的大小
batch_size = 50
# 总容量
capacity = 1000 + 3*batch_size
image_batch_train0, label_batch_train = tf.train.batch([image_train, label_train], batch_size=batch_size,
                                                         capacity=capacity)
# 转化成图像处理可以识别的格式
image_batch_train = tf.decode_raw(image_batch_train0, tf.uint8)

filename_queue_test = tf.train.string_input_producer(["/home/mxqian/Projects/Captcha/captcha_data/Records/"
                                                 "captcha_data_test.tfrecords"])

_, serialized_example = reader.read(filename_queue_test)
features_test = tf.parse_single_example(
    serialized_example,
    features={
        'data': tf.FixedLenFeature([], tf.string),
        'label': tf.FixedLenFeature([], tf.int64)
    })

image_test = features_test['data']
label_test = features_test['label']

# 组合训练数据
# 每个batch中样本量的大小
batch_size = 50
# 总容量
capacity = 1000 + 3*batch_size
image_batch_test0, label_batch_test = tf.train.batch([image_test, label_test], batch_size=batch_size,
                                                    capacity=capacity)
# 转化成图像处理可以识别的格式
image_batch_test = tf.decode_raw(image_batch_test0, tf.uint8)

# # # 创建对话
# with tf.Session() as sess:
#     tf.global_variables_initializer()
#     coord = tf.train.Coordinator()
#     threads = tf.train.start_queue_runners(sess=sess, coord=coord)
#     a = sess.run(image_train)
#     # print(len(a))
#
#     for i in range(62):
#         cur_example_batch, cur_label_batch = sess.run([image_batch_test, label_batch_test])
#         # print(type(cur_label_batch))
#         # print(type(cur_example_batch))
#         # print(cur_example_batch[0])
#         # imag = np.resize(cur_example_batch[0], )
#         # imag = cur_example_batch[9].reshape((16, 16))
#         # plt.imshow(imag)
#         # plt.show()
#         print(np.shape(cur_example_batch))
#         print(np.ndim(cur_label_batch))
#     coord.request_stop()
#     coord.join(threads)



